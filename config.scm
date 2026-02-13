(use-modules (gnu)
             (gnu services desktop)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(operating-system
 ;; Use regular Linux with the big bad proprietary firmware blobs.
 (kernel linux)
 (initrd microcode-initrd)
 ;; sof-firmware is required for sound to work, linux-firmware takes
 ;; care of everything else.
 (firmware (list sof-firmware linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/Mexico_City")
 (keyboard-layout (keyboard-layout "us" "altgr-intl"))
 (host-name "2b")
 (users (cons* (user-account
                (name "willful759")
                (group "users")
                (home-directory "/home/willful759")
                (supplementary-groups '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))

 (packages (append (list (specification->package "nss-certs"))
                   %base-packages))

 (services (modify-services
             (cons (service gnome-desktop-service-type) %desktop-services)

             (service openssh-service-type
                      (oppenssh-configuration
                       (openssh openssh-sans-x)
                       (port-number 22)))

             ;; Get nonguix substitutes.
             (guix-service-type config =>
               (guix-configuration
                 (inherit config)
                 (substitute-urls
                  (append (list
                           "https://ci.guix.gnu.org"
                           "https://bordeaux.guix.gnu.org"
                           "https://substitutes.nonguix.org")
                          %default-substitute-urls))
                 (authorized-keys
                  (append (list (local-file "./nonguix-signing-key.pub"))
                          %default-authorized-guix-keys))))))

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))

 (file-systems (cons* (file-system
                        (mount-point "/")
                        (device "/dev/sda2")
                        (type "btrfs"))
                      (file-system
                       (mount-point "/home")
                       (device "/dev/sda3")
                       (type "btrfs"))
                      %base-file-systems)))
