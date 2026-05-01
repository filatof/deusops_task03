terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "staging-492617"
  region  = "europe-central2"
  zone    = "europe-central2-c"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
