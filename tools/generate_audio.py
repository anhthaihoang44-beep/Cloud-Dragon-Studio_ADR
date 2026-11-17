import wave
import math
import struct
import os

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        # Clamp samples to 16-bit signed int
        packed = bytearray()
        for s in samples:
            val = int(max(-32767, min(32767, s * 32767)))
            packed.extend(struct.pack('<h', val))
        wav_file.writeframes(packed)
    print(f"Generated {filename} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

# 1. Bubble Pop
def generate_pop():
    duration = 0.09
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Frequency drops rapidly from 850Hz to 180Hz
        freq = 850 * math.exp(-t * 28) + 180
        env = math.exp(-t * 35)
        val = math.sin(2 * math.pi * freq * t) * env
        samples.append(val * 0.8)
    return samples

# 2. Sparkle Chimes
def generate_sparkle():
    duration = 0.45
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    notes = [1318.51, 1567.98, 1975.53, 2349.32, 2637.02] # E6, G6, B6, D7, E7
    for idx, f in enumerate(notes):
        start_t = idx * 0.05
        start_sample = int(start_t * SAMPLE_RATE)
        for i in range(start_sample, num_samples):
            t = (i - start_sample) / SAMPLE_RATE
            env = math.exp(-t * 12)
            # Bell overtone
            val = (math.sin(2 * math.pi * f * t) + 0.3 * math.sin(4 * math.pi * f * t)) * env * 0.25
            samples[i] += val
    return samples

# 3. Brush Stroke
def generate_brush():
    duration = 0.16
    num_samples = int(SAMPLE_RATE * duration)
    import random
    samples = []
    r = random.Random(42)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Windowed soft white noise filtered with soft sine
        noise = (r.random() * 2 - 1)
        env = math.sin(math.pi * (i / num_samples)) ** 2
        tone = math.sin(2 * math.pi * 440 * t) * 0.2
        val = (noise * 0.4 + tone) * env * 0.4
        samples.append(val)
    return samples

# 4. Cheer / Delight
def generate_cheer():
    duration = 0.6
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    chords = [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6
    for idx, f in enumerate(chords):
        start_t = idx * 0.06
        start_sample = int(start_t * SAMPLE_RATE)
        for i in range(start_sample, num_samples):
            t = (i - start_sample) / SAMPLE_RATE
            env = math.exp(-t * 7)
            val = (math.sin(2 * math.pi * f * t) + 0.25 * math.sin(3 * math.pi * f * t)) * env * 0.25
            samples[i] += val
    return samples

# 5. Sweet Lullaby / Music Box BGM (16 seconds loop)
def generate_bgm():
    bpm = 100
    beat_dur = 60.0 / bpm  # 0.6s per beat
    total_beats = 24       # 14.4 seconds loop
    num_samples = int(SAMPLE_RATE * total_beats * beat_dur)
    samples = [0.0] * num_samples

    # Melody notes: (beat_offset, frequency, duration, volume)
    # C major / A minor sweet celestial melody
    # C5=523.25, D5=587.33, E5=659.25, G5=783.99, A5=880.0, B5=987.77, C6=1046.50
    melody = [
        # Measure 1 (Cmaj)
        (0.0, 523.25, 1.2, 0.35),
        (1.0, 659.25, 1.0, 0.35),
        (2.0, 783.99, 1.5, 0.4),
        (3.0, 659.25, 1.0, 0.3),
        # Measure 2 (Am)
        (4.0, 880.00, 1.2, 0.4),
        (5.0, 783.99, 1.0, 0.35),
        (6.0, 659.25, 1.5, 0.35),
        # Measure 3 (Fmaj)
        (8.0, 698.46, 1.2, 0.35), # F5
        (9.0, 783.99, 1.0, 0.35),
        (10.0, 880.00, 1.2, 0.4),
        (11.0, 1046.50, 1.5, 0.45), # C6
        # Measure 4 (G7)
        (12.0, 987.77, 1.2, 0.4),  # B5
        (13.0, 783.99, 1.0, 0.35),
        (14.0, 659.25, 1.0, 0.3),
        (15.0, 587.33, 1.5, 0.35), # D5
        # Measure 5 (Em / C reprise)
        (16.0, 659.25, 1.2, 0.35),
        (17.0, 783.99, 1.0, 0.35),
        (18.0, 880.00, 1.0, 0.35),
        (19.0, 1046.50, 1.5, 0.4),
        # Measure 6 (Turnaround)
        (20.0, 987.77, 1.0, 0.35),
        (21.0, 783.99, 1.0, 0.3),
        (22.0, 587.33, 1.0, 0.3),
        (23.0, 523.25, 1.5, 0.4),
    ]

    # Warm Bass accompaniment (C3=130.81, A2=110.0, F2=87.31, G2=98.0)
    bass = [
        (0.0, 261.63, 3.5, 0.2),  # C4
        (4.0, 220.00, 3.5, 0.2),  # A3
        (8.0, 174.61, 3.5, 0.2),  # F3
        (12.0, 196.00, 3.5, 0.2), # G3
        (16.0, 261.63, 3.5, 0.2), # C4
        (20.0, 196.00, 3.5, 0.2), # G3
    ]

    for (start_beat, f, dur, vol) in melody:
        start_sample = int(start_beat * beat_dur * SAMPLE_RATE)
        sample_len = int(dur * beat_dur * SAMPLE_RATE)
        for i in range(sample_len):
            if start_sample + i >= num_samples:
                break
            t = i / SAMPLE_RATE
            # Music box / celesta tone: pure sine + soft 2nd harmonic + exponential decay
            env = math.exp(-t * 2.8) * (1.0 - math.exp(-t * 60))
            tone = (math.sin(2 * math.pi * f * t) + 0.35 * math.sin(4 * math.pi * f * t) + 0.1 * math.sin(6 * math.pi * f * t))
            samples[start_sample + i] += tone * env * vol * 0.45

    for (start_beat, f, dur, vol) in bass:
        start_sample = int(start_beat * beat_dur * SAMPLE_RATE)
        sample_len = int(dur * beat_dur * SAMPLE_RATE)
        for i in range(sample_len):
            if start_sample + i >= num_samples:
                break
            t = i / SAMPLE_RATE
            env = math.exp(-t * 1.5)
            tone = (math.sin(2 * math.pi * f * t) + 0.2 * math.sin(4 * math.pi * f * t))
            samples[start_sample + i] += tone * env * vol * 0.3

    # Normalize BGM so it's sweet and never clips
    max_amp = max(abs(s) for s in samples) or 1.0
    samples = [s / max_amp * 0.65 for s in samples]
    return samples

if __name__ == '__main__':
    out_dir = r"c:\Users\HP\Desktop\Rainbow Unicorn Candy Salon\assets\audio"
    write_wav(os.path.join(out_dir, "pop.wav"), generate_pop())
    write_wav(os.path.join(out_dir, "sparkle.wav"), generate_sparkle())
    write_wav(os.path.join(out_dir, "brush.wav"), generate_brush())
    write_wav(os.path.join(out_dir, "cheer.wav"), generate_cheer())
    write_wav(os.path.join(out_dir, "bgm.wav"), generate_bgm())
