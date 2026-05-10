# Rüya — Memory Consolidation for Claude Code

> Senin gibi rüya gören AI ajanı. Sen uyurken hafızanı düzenler.

`Rüya`, Claude Code'un memory sistemini insan uykusundaki konsolidasyon mantığına göre otomatik düzenleyen bir skill'dir. Anthropic'in resmi `dreaming` özelliği (Mayıs 2026, Managed Agents) bekleyenler için açık kaynak topluluk replikası.

## Ne yapar?

Çok session'lı Claude Code kullanımında auto-memory zaman içinde gürültü biriktirir: bayat tanılar, çelişen kayıtlar, anlam yitiren göreceli tarihler ("dün", "geçen hafta"). `Rüya` 4-fazlı bir konsolidasyon geçişi yapar — beynin uykuda yaptığı şeyin aynısı:

**Faz 1 — Yön bul (Orient):** Mevcut memory dizinini okur, neyin var olduğunu çıkarır.

**Faz 2 — Sinyal topla (Gather Signal):** Son session transcript'lerini (JSONL) tarar — kullanıcı düzeltmeleri, tercih değişiklikleri, kritik kararlar, tekrarlayan örüntüler. Targeted grep, full-read değil.

**Faz 3 — Konsolide et (Consolidate):** Yeni bulguları mevcut memory ile birleştirir. Göreceli tarihleri mutlak yapar ("dün" → "2026-05-09"). Çelişkileri çözer. Var olmayan dosyalara referansları temizler. Duplicate yok.

**Faz 4 — Buda ve indeksle (Prune & Index):** MEMORY.md'yi 200 satır altında tutan yalın indeks olarak yeniden inşa eder. Bayat pointer'ları siler. Uzun girdileri topic dosyalarına demote eder.

## Otomatik tetikleme

Native Claude Code Stop hook her session çıkışında kontrol eder:
- Son rüyadan beri 24+ saat geçti mi?
- Geçtiyse, sonraki session'da `/ruya` otomatik çalışır.

Koşul sağlanmadığında ~10ms (sıfır overhead).

## Memory sistemi auto-detect

İlk kurulumda mevcut memory sistemi tespit edilir:
- **Native Claude Code** (`~/.claude/projects/*/memory/`) — default
- **OpenClaw-style** (`./memory/` daily log)
- **Project-root** (`./MEMORY.md`)

Hiçbiri tespit edilmezse Native varsayılır.

## Hızlı başlangıç

### Seçenek 1: Skills dizinine clone

```bash
git clone https://github.com/alinac-tech/ruya.git ~/.claude/skills/ruya
```

### Seçenek 2: One-command installer

```bash
git clone https://github.com/alinac-tech/ruya.git /tmp/ruya
bash /tmp/ruya/install.sh --auto
```

### Seçenek 3: Manuel install

1. `SKILL.md` ve `should-ruya.sh`'ı `~/.claude/skills/ruya/` altına kopyala
2. `chmod +x ~/.claude/skills/ruya/should-ruya.sh`
3. Claude Code session başlat, `/ruya` yaz

## Dosyalar

| Dosya | Amaç |
|------|------|
| `SKILL.md` | Skill prompt'u — 4-fazlı konsolidasyon talimatları |
| `should-ruya.sh` | 24-saat timer kontrolü |
| `ruya-hook.sh` | Stop hook — sonraki session'ı `/ruya` için bayraklar |
| `install.sh` | One-command installer (`--auto` flag hook setup için) |
| `test-ruya.sh` | Test fixture'ları üretip konsolidasyonu doğrular |

## Kullanım

### Manuel
```
/ruya
```

### Otomatik (`install --auto` sonrası)
Claude Code'u normal kullan. Stop hook her session çıkışında kontrol eder. 24 saat geçtiğinde sonraki session arka planda otomatik rüya konsolidasyonu çalıştırır.

## Gereksinimler

- Claude Code v2.1.59+ (auto-memory desteği)
- Ek bağımlılık yok

## Kaynak

Bu skill, [grandamenium/dream-skill](https://github.com/grandamenium/dream-skill) topluluk projesinin Türkçeleştirilmiş ve özelleştirilmiş forkudur. Anthropic'in resmi `dreaming` (Managed Agents, Mayıs 2026) konseptinden ilham almıştır.

## Lisans

MIT
