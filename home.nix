{ inputs, config, pkgs, lib, ... }:

{
    home.username = "firebat";
    home.homeDirectory = "/home/firebat";

    # config for neovim
    home.file.".config/nvim" = {
        enable = true;
        recursive = true;
        source = ./git_repositories/nvim;
    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        extraPackages = with pkgs; [
            ripgrep               # Required for Telescope
            fd                    # Better find for Telescope
            lua-language-server   # Lua LSP
            nil                   # Nix LSP
        ];
    };

    # config for git
    programs.git = {
        enable = true;
        userName = "firebat";
        userEmail = "66.firebat@gmail.com";
        extraConfig = {
            core.editor = ''nvim --clean -c "set termguicolors" -c "hi Normal guibg=#2b2b2b" -c "hi StatusLine guibg=#2b2b2b guifg=#8a8a8a gui=NONE" -c "hi StatusLineNC guibg=#2b2b2b guifg=#5f5f5f gui=NONE" -c "nnoremap L $" -c "nnoremap H 0"'';
        };
    };

    # config for bash
    programs.bash = {
        enable = true;
        initExtra = builtins.readFile ./git_repositories/bash/.bashrc;
    };                                                                                                                                                                          

    # config for xdg-portal-termfilechooser
    home.file.".config/xdg-desktop-portal-termfilechooser" = {
        enable = true;
        recursive = true;
        source = ./git_repositories/xdg-portal-termfile;
    };

    home.file.".config/xdg-desktop-portal-termfilechooser/ghostty-wrapper.sh" = {
        source = ./git_repositories/xdg-portal-termfile/ghostty-wrapper.sh;
        executable = true;
    };

    # config for sioyek
    home.file.".config/sioyek" = {
        enable = true;
        recursive = true;
        source = ./git_repositories/sioyek;
    };

    # config for sioyek
    home.file.".config/pi" = {
        enable = true;
        recursive = true;
        source = ./git_repositories/sioyek;
    };


    # config for GNOME icons
    home.file.".local/share/icons" = {
        enable = true;
        recursive = true;
        source = ./git_repositories/assets/icon_packs;
    };

    # config for ghostty
    home.file.".config/ghostty" = {
        enable = true;
        recursive = true;
        source = ./git_repositories/ghostty;
    };

    home.stateVersion = "23.11";
    programs.home-manager.enable = true;

    # config for hyprland
    wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        extraConfig = ''require("hyprland-user")'';
        portalPackage = null;
        systemd.enable = true;

        plugins = [
            inputs.hypr-darkwindow.packages.${pkgs.system}.Hypr-DarkWindow
        ];
    };

    xdg.configFile."hypr/hyprland-user.lua".source = ./git_repositories/hyprland/hyprland-user.lua;
    xdg.configFile."hypr/keymaps.lua".source = ./git_repositories/hyprland/keymaps.lua;
    xdg.configFile."hypr/autocmds.lua".source = ./git_repositories/hyprland/autocmds.lua;

    programs.firefox = {
        enable = true;
        policies = {
            ExtensionSettings = {
                "tridactyl.vim@cmcaine.co.uk" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
                    installation_mode = "force_installed";
                };
                "{b83ca28b-caa2-446d-a2e1-4d373c4d6349}" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/videospeed/latest.xpi";
                    installation_mode = "force_installed";
                    default_area = "navbar";
                };
                "FirefoxColor@mozilla.com" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
                    installation_mode = "force_installed";
                };
                "addon@darkreader.org" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
                    installation_mode = "force_installed";
                };
                "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/singlefile/latest.xpi";
                    installation_mode = "force_installed";
                };
                "Tab-Session-Manager@sienori" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-session-manager/latest.xpi";
                    installation_mode = "force_installed";
                };
                "newtaboverride@agenedia.com" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/new-tab-override/latest.xpi";
                    installation_mode = "force_installed";
                };
                "uBlock0@raymondhill.net" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                    installation_mode = "force_installed";
                };
            };
        };
        profiles.firebat = {
            settings = {
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            };
            # userChrome = builtins.readFile ./git_repositories/firefox/userChrome.css;
        };
    };

    home.packages = with pkgs; [
        pavucontrol
        pamixer
    ];

    xdg = {
        portal = {
            enable = lib.mkForce true; 

            extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
                xdg-desktop-portal-termfilechooser
            ];

            config = {
                common = {
                    default = [ "gtk" ];
                    # FIX: Redirect screen sharing requests to hyprland backend instead of wlr
                    "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
                    "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
                    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
                    "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
                    "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
                };

                wlroots = {
                };

                hyprland = {
                    default = [ "hyprland" ];
                    "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
                    "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
                };
            };
        };

        configFile = {
            "xdg-desktop-portal-termfilechooser/config" = {
                force = true;
                executable = true;
                text = ''
[filechooser]
cmd=/home/firebat/.config/xdg-desktop-portal-termfilechooser/ghostty-wrapper.sh
default_dir=$HOME/downloads
create_help_file=1
env=TERMCMD='ghostty --title="filechooser" -e'
env=PATH="$PATH:/run/current-system/sw/bin"
open_mode=suggested
save_mode=last
'';
            };
        };
    };

    systemd.user.tmpfiles.rules = [
        "d %h/.local/state/xdg-desktop-portal-termfilechooser 0755 - - -"
    ];
}
