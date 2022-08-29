
# ./cfautomate.sh
## Cloudflare as Code 


- Create new zones for Cloudflare
- Add/Update/Delete the records 
- Manage the SSL settings
- Add/Delete the rules

Tools required for using the script: 
- cf-terraforming
- cloudflare credentials for authentication_
  - cloudflare_email
  - cloudflare_api_key or cloudflare_key


Run **./cfautomate.sh** to create a new zone or import the existing cloudflare resources into terraform state
then run **modules/{module.name}/import.sh** to import into terraform state

Then your cloudflare zone is imported into terraform state

<!-- Run **./cfnew.sh** to create new zones. You can output the resulting zones and nameservers into terraform output. 
You can use terraform outputs to update into your name registry to start with using Cloudflare nameservers 

By default, it creates a **A record** if the IP provided and **CNAME for www**.  -->
