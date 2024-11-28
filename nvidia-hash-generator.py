import hashlib
import urllib.request
import os
import sys
import base64

def download_file(url):
    try:
        with urllib.request.urlopen(url) as response:
            return response.read()
    except urllib.error.URLError as e:
        print(f"Error downloading {url}: {e}")
        return None

def calculate_sha256(data):
    sha256_bytes = hashlib.sha256(data).digest()
    return base64.b64encode(sha256_bytes).decode('utf-8')

def get_nvidia_hashes(version):
    driver_base = f"https://download.nvidia.com/XFree86/Linux-x86_64/{version}"
    aarch64_base = f"https://download.nvidia.com/XFree86/Linux-aarch64/{version}"
    settings_base = f"https://download.nvidia.com/XFree86/nvidia-settings"
    persistenced_base = f"https://download.nvidia.com/XFree86/nvidia-persistenced"
    
    files = {
        "sha256_64bit": f"{driver_base}/NVIDIA-Linux-x86_64-{version}.run",
        "sha256_aarch64": f"{aarch64_base}/NVIDIA-Linux-aarch64-{version}.run",
        "settingsSha256": f"{settings_base}/nvidia-settings-{version}.tar.bz2",
        "persistencedSha256": f"{persistenced_base}/nvidia-persistenced-{version}.tar.bz2"
    }
    
    results = {}
    
    print("Downloading and calculating hashes...")
    for key, url in files.items():
        try:
            print(f"Processing {url}...")
            content = download_file(url)
            if content:
                sha = calculate_sha256(content)
                results[key] = sha
            else:
                results[key] = "ERROR"
        except Exception as e:
            print(f"Error processing {url}: {e}")
            results[key] = "ERROR"
    
    return results

def format_nix_config(version, hashes):
    config = f"""package = config.boot.kernelPackages.nvidiaPackages.mkDriver {{
    version = "{version}";
    sha256_64bit = "sha256-{hashes['sha256_64bit']}=";
    sha256_aarch64 = "sha256-{hashes['sha256_aarch64']}=";
    openSha256 = "sha256-unknown";
    settingsSha256 = "sha256-{hashes['settingsSha256']}=";
    persistencedSha256 = "sha256-{hashes['persistencedSha256']}=";
}};"""
    return config

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <nvidia-version>")
        print("Example: python script.py 565.57.01")
        return
    
    version = sys.argv[1]
    hashes = get_nvidia_hashes(version)
    nix_config = format_nix_config(version, hashes)
    
    print("\nUpdated Nix configuration:")
    print(nix_config)

if __name__ == "__main__":
    main()
