let
  name = "ollama";
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.1";
    port = 11434;

    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "8";
      OLLAMA_MAX_LOADED_MODELS = "8";
    };

    syncModels = true;

    loadModels = [
      "qwen3.5:9b"
      "gemma4:e4b"
      "ministral-3:8b"
      "granite4.1:8b"

      "embeddinggemma:latest"
    ];
  };
}
