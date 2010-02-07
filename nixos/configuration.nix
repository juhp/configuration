{
  boot = {
    initrd.kernelModules = [  "ata_piix" "uhci_hcd" ];
    kernelModules = [  ];
    loader.grub.device = "/dev/sda";
  };

  fileSystems = [
    { mountPoint = "/";
      label = "nixos";
    }
  ];

# nix.maxJobs = 1;
  
  services = {
    gpm.enable = true;
    locate.enable = true;
    sshd.enable = true;
    xserver = {
      enable = true;
      videoDriver = "cirrus";
    };
  };

  swapDevices = [
    { label = "swap"; }
  ];

  time.timeZone = "Australia/Brisbane";
}
