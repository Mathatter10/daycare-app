package media

import (
	"bytes"
	"encoding/binary"
	"errors"
	"image"
	"image/color"
	"image/jpeg"
	"image/png"
	"strings"
	"testing"
)

// jpegWithOrientation encodes img as JPEG and inserts an EXIF APP1 segment
// carrying the given orientation, like a phone camera does.
func jpegWithOrientation(t *testing.T, img image.Image, orientation uint16) []byte {
	t.Helper()
	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: 95}); err != nil {
		t.Fatal(err)
	}
	raw := buf.Bytes()

	tiff := []byte("II*\x00")
	tiff = binary.LittleEndian.AppendUint32(tiff, 8) // IFD0 offset
	tiff = binary.LittleEndian.AppendUint16(tiff, 1) // one entry
	tiff = binary.LittleEndian.AppendUint16(tiff, 0x0112)
	tiff = binary.LittleEndian.AppendUint16(tiff, 3) // SHORT
	tiff = binary.LittleEndian.AppendUint32(tiff, 1)
	tiff = binary.LittleEndian.AppendUint16(tiff, orientation)
	tiff = append(tiff, 0, 0)
	tiff = binary.LittleEndian.AppendUint32(tiff, 0) // no next IFD
	payload := append([]byte("Exif\x00\x00"), tiff...)

	app1 := []byte{0xFF, 0xE1}
	app1 = binary.BigEndian.AppendUint16(app1, uint16(len(payload)+2))
	app1 = append(app1, payload...)

	out := append([]byte{}, raw[:2]...) // SOI
	out = append(out, app1...)
	return append(out, raw[2:]...)
}

// halves returns a w x h image: left half red, right half blue.
func halves(w, h int) *image.RGBA {
	img := image.NewRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			c := color.RGBA{255, 0, 0, 255}
			if x >= w/2 {
				c = color.RGBA{0, 0, 255, 255}
			}
			img.Set(x, y, c)
		}
	}
	return img
}

func isRed(c color.Color) bool  { r, _, b, _ := c.RGBA(); return r > 0xC000 && b < 0x4000 }
func isBlue(c color.Color) bool { r, _, b, _ := c.RGBA(); return b > 0xC000 && r < 0x4000 }

func TestExifOrientation(t *testing.T) {
	for o := uint16(1); o <= 8; o++ {
		data := jpegWithOrientation(t, halves(20, 10), o)
		if got := exifOrientation(data); got != int(o) {
			t.Errorf("orientation %d: got %d", o, got)
		}
	}
	var plain bytes.Buffer
	_ = jpeg.Encode(&plain, halves(4, 4), nil)
	if got := exifOrientation(plain.Bytes()); got != 1 {
		t.Errorf("no EXIF: got %d, want 1", got)
	}
	if got := exifOrientation([]byte("not a jpeg")); got != 1 {
		t.Errorf("garbage: got %d, want 1", got)
	}
}

func TestProcessPhotoRotatesAndStripsExif(t *testing.T) {
	// Stored landscape 200x100 (red left, blue right) + "rotate 90° CW".
	data := jpegWithOrientation(t, halves(200, 100), 6)

	p, err := ProcessPhoto(data)
	if err != nil {
		t.Fatal(err)
	}
	if p.Width != 100 || p.Height != 200 {
		t.Fatalf("size = %dx%d, want 100x200 (portrait)", p.Width, p.Height)
	}
	img, err := jpeg.Decode(bytes.NewReader(p.Full))
	if err != nil {
		t.Fatal(err)
	}
	// Rotating CW moves the stored left (red) half to the top.
	if top, bottom := img.At(50, 20), img.At(50, 180); !isRed(top) || !isBlue(bottom) {
		t.Errorf("wrong rotation: top=%v bottom=%v, want red over blue", top, bottom)
	}
	for name, out := range map[string][]byte{"full": p.Full, "thumb": p.Thumb} {
		if bytes.Contains(out, []byte("Exif")) {
			t.Errorf("%s still contains EXIF metadata", name)
		}
	}
}

func TestProcessPhotoScalesDown(t *testing.T) {
	var buf bytes.Buffer
	if err := png.Encode(&buf, image.NewRGBA(image.Rect(0, 0, 3000, 2000))); err != nil {
		t.Fatal(err)
	}
	p, err := ProcessPhoto(buf.Bytes())
	if err != nil {
		t.Fatal(err)
	}
	if p.Width != 1600 || p.Height != 1067 {
		t.Errorf("full = %dx%d, want 1600x1067", p.Width, p.Height)
	}
	thumb, err := jpeg.DecodeConfig(bytes.NewReader(p.Thumb))
	if err != nil {
		t.Fatal(err)
	}
	if thumb.Width != 400 || thumb.Height != 267 {
		t.Errorf("thumb = %dx%d, want 400x267", thumb.Width, thumb.Height)
	}
}

func TestProcessPhotoRejects(t *testing.T) {
	if _, err := ProcessPhoto([]byte("definitely not an image")); !errors.Is(err, ErrUnsupportedImage) {
		t.Errorf("garbage: err = %v, want ErrUnsupportedImage", err)
	}

	var buf bytes.Buffer
	if err := png.Encode(&buf, image.NewGray(image.Rect(0, 0, 8000, 6000))); err != nil {
		t.Fatal(err)
	}
	_, err := ProcessPhoto(buf.Bytes())
	if err == nil || !strings.Contains(err.Error(), "too large") {
		t.Errorf("48 MP image: err = %v, want too large", err)
	}
}
