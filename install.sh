#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. This script will install system packages."
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        DISTRO=$ID
    elif [[ -f /etc/redhat-release ]]; then
        OS=$(cat /etc/redhat-release)
        DISTRO="rhel"
    elif [[ -f /etc/debian_version ]]; then
        OS="Debian"
        DISTRO="debian"
    else
        OS=$(uname -s)
        DISTRO="unknown"
    fi
}

check_go() {
    if command -v go &> /dev/null; then
        GO_VERSION=$(go version | awk '{print $3}')
        print_status "Go is already installed: $GO_VERSION"
        return 0
    else
        print_status "Go is not installed. Will install Go..."
        return 1
    fi
}

install_go_debian() {
    print_status "Installing Go on Ubuntu/Debian..."
    sudo apt update
    sudo apt install -y golang-go
    print_success "Go installed successfully on Ubuntu/Debian"
}

install_go_fedora() {
    print_status "Installing Go on Fedora..."
    sudo dnf install -y golang
    print_success "Go installed successfully on Fedora"
}

install_go_arch() {
    print_status "Installing Go on Arch Linux..."
    sudo pacman -S --noconfirm go
    print_success "Go installed successfully on Arch Linux"
}

install_go_rhel() {
    print_status "Installing Go on CentOS/RHEL..."
    sudo yum install -y golang || sudo dnf install -y golang
    print_success "Go installed successfully on CentOS/RHEL"
}

install_go() {
    case $DISTRO in
        "ubuntu"|"debian"|"linuxmint")
            install_go_debian
            ;;
        "fedora")
            install_go_fedora
            ;;
        "arch"|"manjaro"|"endeavouros")
            install_go_arch
            ;;
        "centos"|"rhel"|"rocky"|"almalinux")
            install_go_rhel
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            print_error "Please install Go manually and run this script again"
            exit 1
            ;;
    esac
}

check_source_file() {
    if [[ ! -f "main.go" ]]; then
        print_error "main.go not found in current directory"
        print_error "Please make sure main.go is in the same directory as this script"
        exit 1
    fi
    print_status "Found main.go source file"
}

compile_gocat() {
    print_status "Compiling gocat..."
    if go build -o gocat main.go; then
        print_success "gocat compiled successfully"
    else
        print_error "Failed to compile gocat"
        exit 1
    fi
}

install_to_path() {
    print_status "Installing gocat to /usr/local/bin..."
    if sudo mv gocat /usr/local/bin/; then
        print_success "gocat installed to /usr/local/bin/"
        print_success "You can now use 'gocat' from anywhere in your terminal"
    else
        print_warning "Failed to install to /usr/local/bin/"
        print_warning "You can still use ./gocat from this directory"
    fi
}

test_installation() {
    print_status "Testing gocat installation..."
    if command -v gocat &> /dev/null; then
        echo "Hello, gocat!" | gocat
        print_success "gocat is working correctly!"
    else
        print_warning "gocat not found in PATH, but compilation was successful"
        print_warning "You can run it with ./gocat"
    fi
}

main() {
    echo "================================================"
    echo "           gocat Installation Script            "
    echo "================================================"
    
    check_root
    
    print_status "Detecting operating system..."
    detect_os
    print_status "Detected OS: $OS ($DISTRO)"
    
    if ! check_go; then
        install_go
    fi
    
    if ! command -v go &> /dev/null; then
        print_error "Go installation failed or Go is not in PATH"
        exit 1
    fi
    
    check_source_file
    compile_gocat
    
    read -p "Do you want to install gocat to /usr/local/bin? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_to_path
        test_installation
    else
        print_success "gocat compiled successfully!"
        print_status "You can run it with: ./gocat"
        print_status "Example: echo 'Hello World' | ./gocat"
    fi
    
    echo
    print_success "Installation completed!"
    echo "================================================"
    echo "Usage examples:"
    echo "  echo 'Hello, World!' | gocat"
    echo "  ls -la | gocat"
    echo "  cat somefile.txt | gocat"
    echo "================================================"
}

main "$@"