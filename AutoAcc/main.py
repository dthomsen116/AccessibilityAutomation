from proxmoxer import ProxmoxAPI
import urllib3

urllib3.disable_warnings()

class ProxmoxConnection():
    def __init__(self, creds_filename):
        # Initialize the class with credentials and SmartConnect instance
        self.creds = self.readCreds(creds_filename)
        self.si = None

    def readCreds(self, filename):
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

    def connection(self):
        creds = self.readCreds('.\\creds.txt')
        if creds is None:
            return
        proxmox = ProxmoxAPI("192.168.0.160:8006", user=creds.get('user'), password=creds.get('passwd'), verify_ssl=False)
        #print(proxmox.nodes.get())

# Create an instance of the class and call the connection method
proxmox_connection = ProxmoxConnection('.\\creds.txt')
proxmox_connection.connection()
