from proxmoxer import ProxmoxAPI
import urllib3

urllib3.disable_warnings()

class ProxmoxManager:
    def __init__(self, creds_filename):
        # Initialize the class with credentials and ProxmoxAPI instance
        self.creds = self.readCreds(creds_filename)
        host = self.creds['host']
        self.proxmox = ProxmoxAPI(host, user=self.creds.get('user'), password=self.creds.get('passwd'), verify_ssl=False)

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

    def checkNode(self):
        try:
            # Get the list of nodes
            nodes = self.proxmox("nodes").get()

            print("Connected Nodes:")
            for node in nodes:
                print(f"- {node['node']}:")

                # Get the list of Containers on the node
                containers = self.proxmox(f"nodes/{node['node']}/lxc").get()
                for container in containers:
                    print(f"\t{container['vmid']}. {container['name']} => {container['status']}")

                # Get the list of VMs on the node
                vms = self.proxmox(f"nodes/{node['node']}/qemu").get()
                #print("Virtual Machines on {0}:".format(node['node']))  # Debugging line
                # print(vms)  # Debugging line
                for vm in vms:
                    vname = (f"\t{vm['vmid']}. {vm['name']} => {vm['status']}")
                    print(vname)
        except Exception as e:
            print(f"Error checking nodes: {e}")


    def displayMenu(self):
        print("1. Look at the ProxyBoxy!")  # Add your specific operations here
        print("2. Exit")

    def mainMenu(self):
        while True:
            self.displayMenu()
            choice = input("Enter your choice: ")

            if choice == '1':
                # Add your Proxmox operations here
                self.checkNode()
            elif choice == '2':
                print("Exiting program. Goodbye!")
                break
            else:
                print("Invalid choice. Please try again.")

if __name__ == "__main__":
    creds_filename = 'AutoAcc\creds.txt'
    manager = ProxmoxManager(creds_filename)
    manager.mainMenu()
