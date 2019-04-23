# Golang Version Manager

> Inspired by [NVM](https://github.com/creationix/nvm), a Golang version management toy, created by some dummy programmer dude :)

## Installation 

Using cURL:

```ssh
curl -o- https://raw.githubusercontent.com/sintan1071/govm/master/.install.sh | bash
```

or Wget:

```ssh
wget -qO- https://raw.githubusercontent.com/sintan1071/govm/master/.install.sh | bash
```

After installation, you should reopen your terminal window or you can just run such a command:

```ssh
find ~ -maxdepth 1 -name .\*rc   
```

this command will show you the "your-sh-rc", then you can run the following command

```ssh
source your-sh-rc
```

## Usage

### install

```ssh
govm install 1.12.4
```

this command will install golang version 1.12.4

### list

```ssh
govm list
```

this command will show you the golang version you already installed

### use

```ssh
govm use 1.11.5
```

this commad will change the $GOROOT and your golang version to the version you inputed