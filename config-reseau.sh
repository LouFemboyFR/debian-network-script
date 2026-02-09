#!/bin/bash

# Fonction pour poser une question oui/non
ask_yes_or_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Veuillez repondre par y ou n." ;;
        esac
    done
}

# Fonction pour obtenir une entree non vide
get_non_empty_input() {
    local prompt="$1"
    while true; do
        read -p "$prompt: " input
        if [[ -n "$input" ]]; then
            echo "$input"
            return
        else
            echo "Ce champ ne peut pas etre vide. Veuillez reessayer."
        fi
    done
}

# Fonction pour afficher un menu numerote
show_menu() {
    echo ""
    echo "=== Menu de Configuration Reseau ==="
    echo "1) Configurer une IP fixe"
    echo "2) Configurer DHCP"
    echo "3) Quitter"
    echo ""
}

# Script principal
echo "Bienvenue dans le script de configuration reseau Debian"
echo ""

while true; do
    show_menu
    read -p "Choisissez une option (1, 2 ou 3): " choice

    case $choice in
        1)
            # Configuration IP fixe
            echo ""
            echo "--- Configuration IP Fixe ---"
            INTERFACE=$(get_non_empty_input "Entrez l'interface reseau (ex: eth0, ens33)")
            ADDRESS=$(get_non_empty_input "Entrez l'adresse IP souhaitee")
            NETMASK=$(get_non_empty_input "Entrez le masque de sous-reseau")
            GATEWAY=$(get_non_empty_input "Entrez l'adresse de la passerelle")

            echo ""
            echo "Resume de la configuration :"
            echo "  Interface: $INTERFACE"
            echo "  IP: $ADDRESS"
            echo "  Masque: $NETMASK"
            echo "  Passerelle: $GATEWAY"
            echo ""

            if ask_yes_or_no "Confirmez-vous cette configuration ?"; then
                echo "Configuration IP fixe pour l'interface $INTERFACE..."
                cat <<EOF | sudo tee "/etc/network/interfaces.d/$INTERFACE" > /dev/null
auto $INTERFACE
iface $INTERFACE inet static
    address $ADDRESS
    netmask $NETMASK
    gateway $GATEWAY
EOF
                echo "✓ Configuration appliquee avec succes."
            else
                echo "✗ Configuration annulee."
            fi
            ;;
        2)
            # Configuration DHCP
            echo ""
            echo "--- Configuration DHCP ---"
            INTERFACE=$(get_non_empty_input "Entrez l'interface reseau (ex: eth0, ens33)")

            echo ""
            echo "Resume de la configuration :"
            echo "  Interface: $INTERFACE"
            echo "  Mode: DHCP"
            echo ""

            if ask_yes_or_no "Confirmez-vous cette configuration ?"; then
                echo "Configuration DHCP pour l'interface $INTERFACE..."
                cat <<EOF | sudo tee "/etc/network/interfaces.d/$INTERFACE" > /dev/null
auto $INTERFACE
iface $INTERFACE inet dhcp
EOF
                echo "✓ Configuration appliquee avec succes."
            else
                echo "✗ Configuration annulee."
            fi
            ;;
        3)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Option invalide. Veuillez choisir 1, 2 ou 3."
            ;;
    esac

    # Demande de redemarrage du service reseau
    echo ""
    if ask_yes_or_no "Voulez-vous redemarrer le service reseau maintenant ?"; then
        sudo systemctl restart networking
        echo "✓ Service reseau redemarre. Votre nouvelle configuration est active."
    else
        echo "Veuillez vous souvenir de redemarrer le service reseau plus tard avec: sudo systemctl restart networking"
    fi
done

echo "Configuration script complete."
