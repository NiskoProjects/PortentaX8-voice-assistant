# Portenta Voice Assistant Setup Status

## ✅ Working
- **NLU service**: Running on port 8090
- **Orchestrator**: Container management working
- **Bootstrap automation**: Models download, apt updates work

## 🔧 In Progress
- **ASR (Vosk)**: Fixed libatomic1 dependency, needs rebuild
- **TTS (Piper)**: Needs testing after ASR fix
- **Wake (OpenWakeWord)**: Missing model file `/app/models/hey-nisko.onnx`

## 📋 Next Steps
1. Stop old placeholder containers (llm, probe, vosk alpine containers)
2. Rebuild ASR with libatomic1 fix
3. Create or download wake word model `hey-nisko.onnx`
4. Configure audio to use line-in mic and headphone jack speaker (not Bluetooth)
5. Test full voice pipeline

## 🎯 Audio Configuration Needed
- **Mic**: Line-in AUX input
- **Speaker**: Headphone jack output (not Bluetooth)
- Update `.env` or compose environment variables accordingly
