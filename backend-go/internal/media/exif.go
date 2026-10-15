package media

import "encoding/binary"

// exifOrientation returns the EXIF Orientation tag (1-8) of a JPEG, or 1
// when there is none. Phones usually store photos sideways plus this tag
// instead of rotating the pixels, and Go's JPEG decoder ignores it.
func exifOrientation(jpegData []byte) int {
	const fallback = 1
	b := jpegData
	if len(b) < 4 || b[0] != 0xFF || b[1] != 0xD8 {
		return fallback
	}
	i := 2
	for i+4 <= len(b) {
		if b[i] != 0xFF {
			return fallback
		}
		marker := b[i+1]
		if marker == 0xDA || marker == 0xD9 { // start of scan / end of image
			return fallback
		}
		segLen := int(binary.BigEndian.Uint16(b[i+2:]))
		if segLen < 2 || i+2+segLen > len(b) {
			return fallback
		}
		seg := b[i+4 : i+2+segLen]
		if marker == 0xE1 && len(seg) >= 6 && string(seg[:6]) == "Exif\x00\x00" {
			if o := tiffOrientation(seg[6:]); o >= 1 && o <= 8 {
				return o
			}
			return fallback
		}
		i += 2 + segLen
	}
	return fallback
}

// tiffOrientation reads tag 0x0112 from IFD0 of a TIFF structure.
func tiffOrientation(t []byte) int {
	if len(t) < 8 {
		return 0
	}
	var bo binary.ByteOrder
	switch string(t[:2]) {
	case "II":
		bo = binary.LittleEndian
	case "MM":
		bo = binary.BigEndian
	default:
		return 0
	}
	ifd := int(bo.Uint32(t[4:]))
	if ifd < 8 || ifd+2 > len(t) {
		return 0
	}
	n := int(bo.Uint16(t[ifd:]))
	for k := 0; k < n; k++ {
		e := ifd + 2 + k*12
		if e+12 > len(t) {
			return 0
		}
		if bo.Uint16(t[e:]) == 0x0112 {
			return int(bo.Uint16(t[e+8:])) // SHORT value, left-justified
		}
	}
	return 0
}
