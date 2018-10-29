# USAGE
# python port_scanner.py -H bernardoamc.github.io -p "80, 443"

import optparse
import nmap

def nmapScan(tgtHost, tgtPort):
    nmScan = nmap.PortScanner()
    nmScan.scan(tgtHost, tgtPort)
    print(nmScan.csv())

def main():
    parser = optparse.OptionParser('usage %prog -H <target host> -p "<target ports>"')
    parser.add_option('-H', dest='tgtHost', type='string', help='specify target host')
    parser.add_option('-p', dest='tgtPort', type='string',\
        help='specify target port[s] separated by comma')

    (options, args) = parser.parse_args()
    tgtHost = options.tgtHost
    tgtPorts = str(options.tgtPort).split(', ')

    if (tgtHost == None) | (tgtPorts[0] == None):
        print('[-] You must specify a target host and port[s].')
        exit(0)

    for tgtPort in tgtPorts:
        nmapScan(tgtHost, tgtPort)

if __name__ == '__main__':
    main()
