let
  name = "ollama";
in
{
  services.${name} = {
    enable = true;

    host = "127.0.0.1";
    port = 11434;

    environmentVariables = {
      OLLAMA_LLM_LIBRARY = "cpu";
    };

    loadModels = [
      "qwen3:1.7b"
      "qwen3:4b"

      "qwen3.5:0.8b"
      "qwen3.5:2b"
      "qwen3.5:4b"
      "qwen3.5:122b"

      "embeddinggemma:latest"
    ];
  };
}
