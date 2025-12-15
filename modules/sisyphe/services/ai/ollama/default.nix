{
  services.ollama = {
    enable = true;

    host = "127.0.0.1";
    port = 11434;

    environmentVariables = {
      OLLAMA_LLM_LIBRARY = "cpu";
    };

    loadModels = [
      "qwen3:0.6b"
      "qwen3:1.7b"
      "qwen3:4b"
      "qwen3:8b"
      "qwen3:14b"
      "embeddinggemma:latest"
    ];
  };
}
