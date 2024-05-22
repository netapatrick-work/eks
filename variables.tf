variable startup_install{
  default = "kind-startup-install.sh"
}

variable github_config_url {
default = "https://github.com/netapatrick-work/cdc-geneflow2"
}

variable github_token {
default = "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"
}

variable controller_namespace {
  default="arc-systems"
}

variable runner_set_namespace{
  default="arc-runners"
}

variable runner_image{
  default="patrickameh/action-runner:0.0.1"
}

variable instance_type {
  default="t3.large"
}

variable root_volume_size {
  default="40"
}

variable name_prefix {
  description = "Name prefix for resources"
  type        = string
  default     = "gh-arc"
}
