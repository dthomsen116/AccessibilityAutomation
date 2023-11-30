from proxmoxer import ProxmoxAPI
import urllib3

urllib3.disable_warnings()

def readCreds(filename):
    try:
        with open(filename, 'r') as file:
            creds = {}
            for line in file:
                key, value = line.strip().split('=')
                creds[key.strip()] = value.strip()
            return creds
    except Exception as e:
        print(f"Error reading credentials: {e}")
        return None

def connection():
    creds = readCreds('.\\creds.txt')
    if creds is None:
        return
    proxmox = ProxmoxAPI("192.168.0.160:8006", user=creds.get('user'), password=creds.get('passwd'), verify_ssl=False
                        )
    #print(proxmox.nodes.get())


connection()
