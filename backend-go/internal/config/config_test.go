package config

import "testing"

func TestStorageEndpoint(t *testing.T) {
	for in, want := range map[string]string{
		"abc.r2.cloudflarestorage.com":                          "abc.r2.cloudflarestorage.com",
		"https://abc.r2.cloudflarestorage.com/":                 "abc.r2.cloudflarestorage.com",
		"https://abc.r2.cloudflarestorage.com/daycare-media":    "abc.r2.cloudflarestorage.com",
		" https://abc.r2.cloudflarestorage.com/daycare-media/ ": "abc.r2.cloudflarestorage.com",
		"http://localhost:9000":                                 "localhost:9000",
		"":                                                      "",
	} {
		if got := storageEndpoint(in); got != want {
			t.Errorf("storageEndpoint(%q) = %q, want %q", in, got, want)
		}
	}
}
