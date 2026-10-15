// Package media processes uploaded photos and runs media jobs in the
// background so HTTP handlers return immediately.
package media

import (
	"bytes"
	"errors"
	"fmt"
	"image"
	"image/jpeg"
	_ "image/png" // register decoder
	"math"

	"golang.org/x/image/draw"
	_ "golang.org/x/image/webp" // register decoder
)

const (
	FullMaxEdge  = 1600
	ThumbMaxEdge = 400
	// maxPixels rejects decompression bombs before decoding.
	maxPixels   = 40_000_000
	fullQuality = 82
	thumbQualty = 75
)

var ErrUnsupportedImage = errors.New("unsupported image; send JPEG, PNG or WebP")

// Photo is a processed photo: re-encoded JPEGs with all metadata (EXIF,
// including GPS location) removed.
type Photo struct {
	Full          []byte
	Thumb         []byte
	Width, Height int // of Full
}

// ProcessPhoto decodes an uploaded image, applies its EXIF orientation,
// scales it down to FullMaxEdge and ThumbMaxEdge and re-encodes as JPEG.
func ProcessPhoto(data []byte) (Photo, error) {
	cfg, format, err := image.DecodeConfig(bytes.NewReader(data))
	if err != nil {
		return Photo{}, ErrUnsupportedImage
	}
	if cfg.Width <= 0 || cfg.Height <= 0 || cfg.Width*cfg.Height > maxPixels {
		return Photo{}, fmt.Errorf("image is too large (%dx%d)", cfg.Width, cfg.Height)
	}
	img, _, err := image.Decode(bytes.NewReader(data))
	if err != nil {
		return Photo{}, ErrUnsupportedImage
	}

	orientation := 1
	if format == "jpeg" {
		orientation = exifOrientation(data)
	}

	full := orient(scale(img, FullMaxEdge), orientation)
	thumb := orient(scale(img, ThumbMaxEdge), orientation)

	fullJPEG, err := encodeJPEG(full, fullQuality)
	if err != nil {
		return Photo{}, err
	}
	thumbJPEG, err := encodeJPEG(thumb, thumbQualty)
	if err != nil {
		return Photo{}, err
	}
	b := full.Bounds()
	return Photo{Full: fullJPEG, Thumb: thumbJPEG, Width: b.Dx(), Height: b.Dy()}, nil
}

// scale fits img inside maxEdge x maxEdge, never enlarging. The result is
// always a fresh RGBA so the original decoder buffers can be freed.
func scale(img image.Image, maxEdge int) *image.RGBA {
	b := img.Bounds()
	w, h := b.Dx(), b.Dy()
	if f := float64(maxEdge) / float64(max(w, h)); f < 1 {
		w = max(1, int(math.Round(float64(w)*f)))
		h = max(1, int(math.Round(float64(h)*f)))
	}
	dst := image.NewRGBA(image.Rect(0, 0, w, h))
	draw.CatmullRom.Scale(dst, dst.Bounds(), img, b, draw.Src, nil)
	return dst
}

// orient applies an EXIF orientation (1-8) so the image displays upright.
func orient(src *image.RGBA, orientation int) *image.RGBA {
	if orientation < 2 || orientation > 8 {
		return src
	}
	w, h := src.Bounds().Dx(), src.Bounds().Dy()
	dw, dh := w, h
	if orientation >= 5 { // 5-8 swap width and height
		dw, dh = h, w
	}
	dst := image.NewRGBA(image.Rect(0, 0, dw, dh))
	for y := 0; y < dh; y++ {
		for x := 0; x < dw; x++ {
			var sx, sy int
			switch orientation {
			case 2: // mirrored horizontally
				sx, sy = w-1-x, y
			case 3: // rotated 180
				sx, sy = w-1-x, h-1-y
			case 4: // mirrored vertically
				sx, sy = x, h-1-y
			case 5: // transposed
				sx, sy = y, x
			case 6: // rotated 90 CW to display
				sx, sy = y, h-1-x
			case 7: // transversed
				sx, sy = w-1-y, h-1-x
			case 8: // rotated 90 CCW to display
				sx, sy = w-1-y, x
			}
			si := src.PixOffset(sx, sy)
			di := dst.PixOffset(x, y)
			copy(dst.Pix[di:di+4], src.Pix[si:si+4])
		}
	}
	return dst
}

func encodeJPEG(img image.Image, quality int) ([]byte, error) {
	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: quality}); err != nil {
		return nil, fmt.Errorf("encode jpeg: %w", err)
	}
	return buf.Bytes(), nil
}
