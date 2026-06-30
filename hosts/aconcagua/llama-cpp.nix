{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
    # package = pkgs.llama-cpp-rocm;
    # package =
    #   with pkgs;
    #   (llama-cpp-rocm.overrideAttrs (oldAttrs: {
    #     DGFX_VERSION = "11.5.0";
    #     # FORCE_REBUILD = builtins.currentTime;
    #     # Adding a dummy attribute forces a local build
    #     # passthru = (oldAttrs.passthru or { }) // {
    #     #   forceRebuild = 1;
    #     # };
    #   }));
    openFirewall = true;
    settings = {
      port = 8093;

      models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" {
        "gemma-4-26B-A4B" = {
          hf-repo = "unsloth/gemma-4-26B-A4B-it-GGUF";
          hf-file = "gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf";
          alias = "unsloth/gemma-4-26B-A4B-it";
          ctx-size = "268288"; # 262K
          temp = "1.0";
          top-p = "0.95";
          top-k = "64";
        };
        "Qwen3.6-35B-A3B-MTP" = {
          hf-repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
          hf-file = "Qwen3.6-35B-A3B-UD-Q6_K_XL.gguf";
          alias = "unsloth/Qwen3.6-35B-A3B-MTP";
          flash-attn = "on";
          temp = "1.0";
          top-p = "0.95";
          top-k = "20";
          min-p = "0.0";
          presence-penalty = "0.0";
          repeat-penalty = "1.0";
          ctx-size = "90112";
          spec-type = "draft-mtp";
          np = "1";
          spec-draft-n-max = "2";
          reasoning-budget = "1024";
          reasoning-budget-message = "Proceed to final answer.";
          cache-type-k = "q8_0";
          cache-type-v = "q8_0";
        };
        "Qwen3-Coder-Next" = {
          hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
          hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
          alias = "unsloth/Qwen3-Coder-Next";
          temp = "1.0";
          top-p = "0.95";
          top-k = "40";
          ctx-size = "65536";
        };
        # "sweep-next-edit" = {
        #   hf-repo = "sweepai/sweep-next-edit-1.5B";
        #   hf-file = "sweep-next-edit-1.5b.q8_0.v2.gguf";
        #   alias = "sweepai/sweep-next-edit-1.5B";
        #   ctx-size = "8192";
        # };
      };
    };

    # port = 8093;
    # List of params supported:
    # https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
    # modelsPreset = {
    #   # TODO: Keep
    #   # - nemotron
    #   "medgemma-1.5-4b-it" = {
    #     hf-repo = "unsloth/medgemma-1.5-4b-it-GGUF";
    #     hf-file = "medgemma-1.5-4b-it-UD-Q8_K_XL.gguf";
    #     alias = "unsloth/medgemma-1.5-4b-it";
    #     flash-attn = "on";
    #     ctx-size = "131072"; # 128K
    #     temp = "0.0";
    #     jinja = true;
    #     reasoning-format = "deepseek";
    #     # special = true;
    #     # chat-template = "chatml";
    #     # <unused95>
    #   };

    #   "translategemma-12b" = {
    #     hf-repo = "bullerwins/translategemma-12b-it-GGUF";
    #     hf-file = "translategemma-12b-it-Q4_0.gguf";
    #     alias = "bullerwins/translategemma-12b-it";
    #     ctx-size = "2048"; # 2K
    #     temp = "1.0";
    #     top-p = "0.95";
    #     top-k = "64";
    #   };
    # --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.00 --presence-penalty 0 --metrics --jinja --chat-template-file chat_template.jinja --chat-template-kwargs '{"preserve_thinking": true}' --spec-type draft-mtp --spec-draft-n-max 2 --spec-draft-p-min 0.75 -ngl 99 -c 131072 -fa on -np 1 -hf unsloth/Qwen3.6-27B-MTP-GGUF:Q6_K
    #   "Qwen3.6-35B-A3B" = {
    #     hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF";
    #     hf-file = "Qwen3.6-35B-A3B-UD-Q6_K_XL.gguf";
    #     alias = "unsloth/Qwen3.6-35B-A3B";
    #     flash-attn = "on";
    #     temp = "1.0";
    #     top-p = "0.95";
    #     top-k = "20";
    #     min-p = "0.0";
    #     presence-penalty = "0.0";
    #     repeat-penalty = "1.0";
    #     ctx-size = "90112";
    #     reasoning-budget = "1024";
    #     reasoning-budget-message = "Proceed to final answer.";
    #   };

    #   "Qwen3.5-2B-MTP-no-thinking" = {
    #     hf-repo = "unsloth/Qwen3.5-2B-MTP-GGUF";
    #     hf-file = "Qwen3.5-2B-UD-Q4_K_XL.gguf";
    #     alias = "unsloth/Qwen3.5-2B-MTP";
    #     flash-attn = "on";
    #     temp = "1.0";
    #     top-p = "1.0";
    #     top-k = "20";
    #     min-p = "0.0";
    #     presence-penalty = "2.0";
    #     repeat-penalty = "1.0";
    #     ctx-size = "4096";
    #     spec-type = "draft-mtp";
    #     np = "1";
    #     spec-draft-n-max = "2";
    #     reasoning = "off";
    #     n-predict = 64;
    #     # Focus on a single request and drop everything to process only the latest request
    #     parallel = "1";

    #     # Force the server to calculate only the absolute newest letters just typed,
    #     # rather than reprocessing the entire prompt from scratch
    #     cache-prompt = "true";
    #     cont-batching = "true";

    #     # Thread allocation tailored to the Strix Point architecture
    #     threads = 4;
    #     threads-batch = 12;
    #     # Offload all layers to the iGPU via ROCm for near-instant prefill
    #     n-gpu-layers = "99";
    #   };
    #   "Hy-MT2-1.8B" = {
    #     hf-repo = "tencent/Hy-MT2-1.8B-GGUF";
    #     hf-file = "Hy-MT2-1.8B-Q8_0.gguf";
    #     alias = "tencent/Hy-MT2-1.8B-GGUF";
    #     ctx-size = "4096";
    #     temp = "0.7";
    #     top-p = "0.6";
    #     top-k = "20";
    #     repeat-penalty = "1.05";

    #   };
    #   "zeta-2.1-i1" = {
    #     hf-repo = "mradermacher/zeta-2.1-i1-GGUF";
    #     hf-file = "zeta-2.1.i1-Q4_K_M.gguf";
    #     alias = "mradermacher/zeta-2.1";
    #     ctx-size = "4096";
    #     batch-size = "4096";

    #     flash-attn = "on";
    #     n-predict = 64;
    #     # Ensure the engine frequently hits structural "checkpoints" where it can see that Zed canceled the request, dropping it much faster
    #     ubatch-size = "512";

    #     # Focus on a single request and drop everything to process only the latest request
    #     parallel = "1";

    #     # Force the server to calculate only the absolute newest letters just typed,
    #     # rather than reprocessing the entire prompt from scratch
    #     cache-prompt = "true";
    #     cont-batching = "true";

    #     # Offload all layers to the iGPU via ROCm for near-instant prefill
    #     n-gpu-layers = "99";

    #     # Retain native, raw FP16 precision for short context speeds
    #     cache-type-k = "f16";
    #     cache-type-v = "f16";

    #     # Lock model weights into physical memory
    #     mlock = true;

    #     # Escalate kernel scheduling to Realtime/High priority
    #     prio = 2;
    #     prio-batch = 3;

    #     reasoning = "off";
    #     # Thread allocation tailored to the Strix Point architecture
    #     threads = 4;
    #     threads-batch = 12;
    #   };
    # };
    # };
  };
  systemd.services.llama-cpp = {
    environment = {
      # Spoof a widely supported architecture if ROCm doesn't natively map gfx1151
      HSA_OVERRIDE_GFX_VERSION = "11.5.1";
      # Direct the Vulkan driver to use systemd's pre-created writable cache
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    };
  };

}
