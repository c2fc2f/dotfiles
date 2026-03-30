let
  name = "ollama";
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.1";
    port = 11434;

    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "4";
      OLLAMA_MAX_LOADED_MODELS = "4";
    };

    loadModels = [
      "qwen3.5:0.8b"
      "qwen3.5:2b"
      "qwen3.5:4b"
      "qwen3.5:122b"

      "ministral-3:3b"
      "ministral-3:8b"

      "embeddinggemma:latest"
    ];
  };
}
