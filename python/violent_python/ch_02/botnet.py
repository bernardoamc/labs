# Script to connect to machines through ssh and run commands

# The config file can have the following options:
# auth_type;hostname;username;auth
#   auth_type being one of:
#     - auth_pass (the auth provided needs to be a password with this option)
#     - auth_key (the auth provided needs to be the path of your key with this option)

import optparse
from pexpect import pxssh

class Client:
    def __init__(self, auth_type, host, user, auth):
        self.auth_type = auth_type
        self.host = host
        self.user = user
        self.auth = auth
        self.session = self.connect()

    def connect(self):
        try:
            s = pxssh.pxssh()

            if self.auth_type == 'auth_pass':
                s.login(self.host, self.user, self.auth)
            elif self.auth_type == 'auth_key':
                s.login(self.host, self.user, ssh_key=self.auth)
            else:
                raise Exception('Invalid auth_type for: %s' % self.host)

            return s
        except Exception as e:
            print(e)
            print('[-] Error Connecting')

    def send_command(self, cmd):
        self.session.sendline(cmd)
        self.session.prompt()
        return self.session.before

def botnetCommand(botNet, command):
    for client in botNet:
        output = client.send_command(command)
        print('[*] Output from ' + client.host)
        print('[+] ' + output.decode() + '\n')

def addClient(auth_type, host, user, password):
    return Client(auth_type, host, user, password)

def main():
    parser = optparse.OptionParser('usage %prog -c <config file>')
    parser.add_option('-c', dest='configFile', type='string', help='specify config file path')

    (options, args) = parser.parse_args()
    configFilePath = options.configFile

    if (configFilePath == None):
        print('[-] You must specify a configuration file.')
        exit(0)

    configFile = open(configFilePath)
    botNet = []

    for line in configFile.readlines():
        config = line.strip("\n")
        options = str(config).split(';')
        botNet.append(addClient(options[0], options[1], options[2], options[3]))

    botnetCommand(botNet, 'uname -v')

if __name__ == '__main__':
    main()
