#!/bin/bash

# Installs a package. Checks if successful. If not, exits terminal.
install_package() {
    PACKAGE_NAME=$1

    if ! command -v $PACKAGE_NAME &> /dev/null
    then
        echo "$PACKAGE_NAME is not installed. Installing..."
        sudo apt-get update
        if sudo apt-get install -y $PACKAGE_NAME; then
            echo "$PACKAGE_NAME has been successfully installed. :)"
        else
            echo "Failed to install $PACKAGE_NAME. Please check your package manager or network connection. :'("
            exit 1 
        fi
    else
        echo "$PACKAGE_NAME is already installed. :)"
    fi
}

# Downloads and installs a .deb package. Checks if successful. If not, exits terminal.
install_dpkg() {
    PACKAGE_URL=$1
    DEB_PACKAGE=$(basename "$PACKAGE_URL")
    PACKAGE_NAME=$(dpkg-deb -f "$DEB_PACKAGE" Package)

    # Check if the package is already installed
    if dpkg -l | grep -q "$PACKAGE_NAME"; then
        echo "$PACKAGE_NAME is already installed. Skipping installation. :)"
        return
    fi

    # Download the .deb package
    echo "Downloading $DEB_PACKAGE from $PACKAGE_URL..."
    wget "$PACKAGE_URL"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download $DEB_PACKAGE. :("
        exit 1
    fi

    # Install the downloaded .deb package
    echo "Installing $DEB_PACKAGE..."
    sudo dpkg -i "$DEB_PACKAGE"

    # Check if the installation was successful
    if [ $? -eq 0 ]; then
        echo "Installation of $DEB_PACKAGE was successful. :)"
    else
        echo "Installation of $DEB_PACKAGE failed. Checking for missing dependencies..."
        sudo apt-get install -f
        if [ $? -eq 0 ]; then
            echo "Missing dependencies have been resolved."
            echo "Please rerun this script to install $DEB_PACKAGE."
            exit 1
        else
            echo "Failed to resolve missing dependencies."
            exit 1
        fi
    fi
}

# Function to clone a Git repository. Checks if successful. If not, exits terminal.
clone_repo() {
    REPO_URL=$1
    DIR_NAME=$2

    # Check if the directory already exists.
    if [ -d "$DIR_NAME" ]; then
        echo "Directory $DIR_NAME already exists. Deleting it..."
        rm -rf "$DIR_NAME"
        echo "Deleted $DIR_NAME"
    fi

    # Clone the repository.
    echo "Cloning the repository from $REPO_URL..."
    git clone "$REPO_URL" "$DIR_NAME"

    # Check if the cloning was successful.
    if [ $? -eq 0 ]; then
        echo "Cloning successful. :)"
    else
        echo "Cloning failed. :("
        exit 1
    fi
}

# Restore and build .NET solution. Checks if successful. If not, exits terminal.
dotnet_restore_and_build() {
    PROJECT_DIR=$1

    # Check if the directory exists.
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Error: Directory $PROJECT_DIR does not exist."
        exit 1
    fi

    # Change to the specified directory.
    cd "$PROJECT_DIR" || { echo "Failed to change directory to $PROJECT_DIR"; exit 1; }

    # Run dotnet restore.
    echo "Running dotnet restore in $PROJECT_DIR..."
    dotnet restore

    # Check if restore was successful:
    if [ $? -eq 0 ]; then
        echo "dotnet restore successful."
    else
        echo "dotnet restore failed."
        exit 1
    fi

    # Run dotnet build.
    echo "Running dotnet build in $PROJECT_DIR..."
    dotnet build

    # Check if build was successful.
    if [ $? -eq 0 ]; then
        echo "dotnet build successful."
    else
        echo "dotnet build failed."
        exit 1
    fi
}

# Runs a .NET project. Checks if successful. If not, exits terminal.
dotnet_run_project() {
    PROJECT_NAME=$1

    # Run the dotnet run command.
    echo "Running dotnet project: $PROJECT_NAME..."
    dotnet run --project "$PROJECT_NAME"

    # Check if the run was successful.
    if [ $? -eq 0 ]; then
        echo "dotnet run successful for project $PROJECT_NAME."
    else
        echo "dotnet run failed for project $PROJECT_NAME."
        exit 1
    fi
}

# First we check if git is installed, and if not, install it! :)
install_package git

# Then we clone the repository. :)
clone_repo "https://github.com/pkg-dot-zip/AvaloniaWindowsAndLinuxButtonPressCounter.git" "AvaloniaWindowsAndLinuxButtonPressCounter"

# Check if wget is installed.
install_package wget

# Install microsoft packages :'(
install_dpkg "https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb"

# dotnetsdk & stuff.
install_package apt-transport-https
install_package dotnet-sdk-8.0

# Then build the solution:
dotnet_restore_and_build "AvaloniaWindowsAndLinuxButtonPressCounter"

# Then run the project.
dotnet_run_project "AvaloniaWindowsAndLinuxButtonPressCounter.Desktop"