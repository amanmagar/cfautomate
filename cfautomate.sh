#!/bin/bash
echo "It also provides the template for a new terraform repository and initialize with cloudflare provider"
printf "Cf-Terraform-Automate - A shell script to automate the zone creation , DNS management and other features of Cloudflare. It also provides the template for a new terraform repository and initialize with cloudflare provider\nChoose from [1-4] to do specific functions from cloudflare\n1.Initiate a new terraform repository\n2.Create new zone\n3.Import cloudflare resources into the terraform\n4.Exit\n"
read cf_option
echo "cloudflare_email:"
read cf_email
echo "cloudflare_key"
read cf_key

if [ $cf_option -eq '1' ];
then
    echo "Creating a new terraform repository and initializing the cloudflare in it"
    echo "Please provide the reposistory name"
    read repo_name
    mkdir -p $repo_name/modules 
    touch $repo_name/{main.tf,secret.tfvars}
    echo 'terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
  }

  variable "cloudflare_email" {
    description = "Email authentication for cloudflare"
    type        = string
    sensitive   = true
  }

  variable "cloudflare_key" {
    description = "Key for cloudflare"
    type        = string
    sensitive   = true
  }  

  provider "cloudflare" {
    email = var.cloudflare_email
    api_key =  var.cloudflare_key
  }

  ' > $repo_name/main.tf

  echo 'cloudflare_email="'$cf_email'"
  cloudflare_key="'$cf_key'"' > $repo_name/secret.tfvars

  cd $repo_name/ && terraform init


elif [ $cf_option -eq '2' ];  
then 
    echo "Please provide the module name {website_name}" 
    read module_name
    echo "Please provide the website prefix (org,com,com.np) " 
    read domain_prefix
    echo "Creating new zone in cloudflare with the provided credentials, the nameservers and zone id are outputed after terraform apply  "
        mkdir -p modules/$module_name

    echo -e 'module "'$module_name'" {
    source                     = "./modules/'$module_name'"
    providers = {
        cloudflare = cloudflare
    }
    }

    '  >> main.tf

    echo 'resource "cloudflare_zone" "domain-'$module_name'" {
    zone = "'$module_name'.'$domain_prefix'"
    plan = "free"
    }


    ' >> modules/$module_name/register.tf

    echo -e 'output "zone_id_'$module_name'" {
        description = "Zone id of '$module_name'"
    value = module.'$module_name'.zone_id_'$module_name'
    }

    output "nameservers_'$module_name'" {
    value = module.'$module_name'.nameservers_'$module_name'
    }

    ' >> output.tf

    echo 'terraform {
    required_providers {
        cloudflare = {
        source = "cloudflare/cloudflare"
        version = "~> 3.0"
        }
    }
    }
    
    output "zone_id_'$module_name'" {
    value = cloudflare_zone.domain-'$module_name'.id
    }

    output "nameservers_'$module_name'" {
    value = cloudflare_zone.domain-'$module_name'.name_servers
    }

    ' >> modules/$module_name/provider.tf

    terraform init
    terraform apply  --var-file=secret.tfvars --target=module.$module_name
elif [ $cf_option -eq '3' ]; 
then
    echo "Please provide the module name {website_name-domain_prefix}"
    read module_name
    echo "Please provide the zone id "
    read zone_id
        mkdir -p modules/$module_name

    echo -e 'module "'$module_name'" {
    source                     = "./modules/'$module_name'"
    providers = {
        cloudflare = cloudflare
    }
    }

    '  >> main.tf

    echo 'terraform {
    required_providers {
        cloudflare = {
        source = "cloudflare/cloudflare"
        version = "~> 3.0"
        }
    }
    }' >> modules/$module_name/provider.tf

    terraform init

    cf-terraforming generate  --resource-type "cloudflare_record" --email $cf_email --key $cf_key  --zone $zone_id > modules/$module_name/records.tf

    cf-terraforming import  --resource-type "cloudflare_record" --email $cf_email --key $cf_key  --zone $zone_id > modules/$module_name/import.sh

else
    echo "Ending the cfautomate script. Thank You"
fi  