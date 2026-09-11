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
      "qwen3.8-flash-next:125b-a6b-q4_K_M"

      "embeddinggemma:latest"
    ];
  };
}
