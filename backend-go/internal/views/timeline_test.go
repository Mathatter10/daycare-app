package views

import (
	"bytes"
	"context"
	"os"
	"strings"
	"testing"
	"time"
)

func sampleReport() TimelineReport {
	loc := time.FixedZone("WIB", 7*3600)
	at := func(h, m int) time.Time { return time.Date(2026, 10, 20, h, m, 0, 0, loc) }
	return TimelineReport{
		ChildID: "c1", ChildName: "Qiara", Nickname: "Qia", ClassName: "Baby",
		DateOfBirth: time.Date(2025, 8, 16, 0, 0, 0, 0, time.UTC),
		Allergies:   "Kacang", ParentName: "Faisal", ParentPhone: "0812",
		Date: at(0, 0), PrevDate: "2026-10-19", NextDate: "2026-10-21",
		Entries: []TimelineEntry{
			{At: at(14, 27), Kind: "checkin", Title: "✅ Tiba (check-in)", By: "Nadia"},
			{At: at(14, 30), Kind: "activity", Title: "🧻 Qia ke toilet", Description: "Pipis dan BAB", By: "Nadia"},
			{
				At: at(14, 31), Kind: "activity", Title: "💊 Catatan kesehatan Qia", Description: "Suhu 36.5°C", By: "Nadia",
				Deleted: true, Audit: []string{"DIHAPUS 20 Okt 2026 15:29 oleh (tidak tercatat)"},
			},
			{
				At: at(14, 40), Kind: "activity", Title: "🍼 Qia makan", Description: "Habis semua", By: "Nadia",
				Audit: []string{"Masuk ke server 15:25 (45 menit setelah kejadian)"},
			},
			{At: at(15, 27), Kind: "media", Title: "📷 Foto", By: "Nadia", URL: "https://example.com/p.jpg", ThumbURL: "https://example.com/t.jpg"},
		},
		ActivityCount: 2, DeletedCount: 1, MediaCount: 1,
		GeneratedAt: at(16, 0), GeneratedBy: "Admin",
	}
}

func TestTimelineBodyShowsDeletionsAndAudit(t *testing.T) {
	var buf bytes.Buffer
	if err := TimelineBody(sampleReport()).Render(context.Background(), &buf); err != nil {
		t.Fatal(err)
	}
	html := buf.String()
	for _, want := range []string{
		"Selasa, 20 Oktober 2026",
		"⚠ Kacang",
		"line-through", // deleted activity is struck through, not hidden
		"DIHAPUS 20 Okt 2026 15:29",
		"45 menit setelah kejadian",
		"1 dihapus",
		"https://example.com/t.jpg",
		"?date=2026-10-21",
	} {
		if !strings.Contains(html, want) {
			t.Errorf("rendered timeline lacks %q", want)
		}
	}
	// Report order is the order of Entries (the handler sorts them).
	if strings.Index(html, "14:27") > strings.Index(html, "15:27") {
		t.Error("entries out of order")
	}

	// Manual preview: TIMELINE_PREVIEW=out.html go test ./internal/views
	if out := os.Getenv("TIMELINE_PREVIEW"); out != "" {
		var page bytes.Buffer
		p := Page{Title: "Timeline Qiara", Nav: "children", AdminName: "Admin"}
		if err := ChildTimelinePage(p, sampleReport()).Render(context.Background(), &page); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(out, page.Bytes(), 0o644); err != nil {
			t.Fatal(err)
		}
	}
}

func TestLongDate(t *testing.T) {
	if got := longDate(time.Date(2026, 10, 21, 0, 0, 0, 0, time.UTC)); got != "Rabu, 21 Oktober 2026" {
		t.Errorf("longDate = %q", got)
	}
}
