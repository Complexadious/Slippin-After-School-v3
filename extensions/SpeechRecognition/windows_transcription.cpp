#define SpeechRecognition_Create
extern "C" {
    #include <windows.h>
    #include <sapi.h>
    #include <sphelper.h> // For helper functions
    #include <mmdeviceapi.h>
    #include <endpointvolume.h>

    void ListAudioInputDevices() {
        IMMDeviceEnumerator* pEnumerator = NULL;
        IMMDeviceCollection* pCollection = NULL;
        IMMDevice* pDevice = NULL;
        IPropertyStore* pProps = NULL;

        CoInitialize(NULL);
        HRESULT hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, __uuidof(IMMDeviceEnumerator), (void**)&pEnumerator);
        if (FAILED(hr)) {
            OutputDebugString("Failed to create MMDeviceEnumerator.\n");
            return;
        }

        hr = pEnumerator->EnumAudioEndpoints(eCapture, DEVICE_STATE_ACTIVE, &pCollection);
        if (FAILED(hr)) {
            OutputDebugString("Failed to enumerate audio endpoints.\n");
            pEnumerator->Release();
            return;
        }

        UINT count;
        hr = pCollection->GetCount(&count);
        if (FAILED(hr)) {
            OutputDebugString("Failed to get audio endpoint count.\n");
            pCollection->Release();
            pEnumerator->Release();
            return;
        }

        for (UINT i = 0; i < count; i++) {
            hr = pCollection->Item(i, &pDevice);
            if (SUCCEEDED(hr)) {
                hr = pDevice->OpenPropertyStore(STGM_READ, &pProps);
                if (SUCCEEDED(hr)) {
                    PROPVARIANT varName;
                    PropVariantInit(&varName);

                    hr = pProps->GetValue(PKEY_Device_FriendlyName, &varName);
                    if (SUCCEEDED(hr)) {
                        // Log the device name
                        OutputDebugString("Audio Input Device: ");
                        OutputDebugStringW(varName.pwszVal);
                        OutputDebugString("\n");
                        PropVariantClear(&varName);
                    }
                    pProps->Release();
                }
                pDevice->Release();
            }
        }

        pCollection->Release();
        pEnumerator->Release();
    }

    ISpRecognizer* recognizer = NULL;
    ISpRecoContext* context = NULL;
    ISpRecoGrammar* grammar = NULL;

    double __cdecl SpeechRecognition_Initialize() {
        // Initialize COM
        HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
        if (FAILED(hr)) {
            OutputDebugString("COM initialization failed.\n");
            return 0;
        }

        // Create recognizer
        hr = CoCreateInstance(CLSID_SpInprocRecognizer, NULL, CLSCTX_ALL, IID_ISpRecognizer, (void**)&recognizer);
        if (FAILED(hr)) {
            OutputDebugString("Failed to create recognizer.\n");
            return 0;
        }

        // Set the default audio input device
        hr = recognizer->SetInput(NULL, TRUE);
        if (FAILED(hr)) {
            OutputDebugString("Failed to set the default audio input.\n");
            return 0;
        }

        // Create recognition context
        hr = recognizer->CreateRecoContext(&context);
        if (FAILED(hr)) {
            OutputDebugString("Failed to create recognition context.\n");
            return 0;
        }

        // Create grammar
        hr = context->CreateGrammar(1, &grammar);
        if (FAILED(hr)) {
            OutputDebugString("Failed to create grammar.\n");
            return 0;
        }

        OutputDebugString("SpeechRecognition_Initialize succeeded.\n");
        return 1;
    }

    double __cdecl SpeechRecognition_AddWord(char* word) {
        if (!grammar) return 0;

        SPSTATEHANDLE rule;
        HRESULT hr = grammar->GetRule(L"DynamicRule", 0, SPRAF_Dynamic, TRUE, &rule);
        if (FAILED(hr)) {
            OutputDebugString("Failed to get grammar rule.\n");
            return 0;
        }

        hr = grammar->AddWordTransition(rule, NULL, word, NULL, SPWT_LEXICAL, 1.0, NULL);
        if (FAILED(hr)) {
            OutputDebugString("Failed to add word transition.\n");
            return 0;
        }

        return 1; // Success
    }

    double __cdecl SpeechRecognition_StartListening() {
        if (!grammar) return 0;

        HRESULT hr = grammar->Commit(NULL);
        if (FAILED(hr)) {
            OutputDebugString("Failed to commit grammar.\n");
            return 0;
        }

        hr = grammar->SetRuleState(NULL, NULL, SPRS_ACTIVE);
        if (FAILED(hr)) {
            OutputDebugString("Failed to activate grammar rules.\n");
            return 0;
        }

        return 1; // Success
    }

    double __cdecl SpeechRecognition_CheckWord() {
        SPEVENT event;
        ULONG eventFetched = 0;

        while (context->GetEvents(1, &event, &eventFetched) == S_OK) {
            if (event.eEventId == SPEI_RECOGNITION) {
                ISpRecoResult* result = (ISpRecoResult*)event.lParam;
                wchar_t* text = NULL;
                if (SUCCEEDED(result->GetText(SP_GETWHOLEPHRASE, SP_GETWHOLEPHRASE, TRUE, &text, NULL))) {
                    OutputDebugStringW(L"Recognized Speech: ");
                    OutputDebugStringW(text);
                    OutputDebugStringW(L"\n");

                    static char buffer[256];
                    wcstombs(buffer, text, sizeof(buffer));
                    CoTaskMemFree(text);
                    return (double)(intptr_t)buffer; // Return recognized text
                }
            }
        }
        return "";
    }

    double __cdecl SpeechRecognition_Cleanup() {
        if (grammar) grammar->Release();
        if (context) context->Release();
        if (recognizer) recognizer->Release();
        CoUninitialize();
        return 1; // Success
    }
}
