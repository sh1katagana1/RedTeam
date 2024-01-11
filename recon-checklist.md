# Recon Checklist
When you are looking to test a target, its best to be as efficient as possible. This all starts with good recon on the target. This is a checklist for some different recon techniques.
## ASN
You need to start by gathering all IP ranges you can on the target. Lets start with Autonomous System Number of the company. The Internet is a network of networks*, and autonomous systems are the big networks that make up the Internet. More specifically, an autonomous system (AS) is a large network or group of networks that has a unified routing policy. Every computer or device that connects to the Internet is connected to an AS. Every AS controls a specific set of IP addresses, just as every town's post office is responsible for delivering mail to all the addresses within that town. The range of IP addresses that a given AS has control over is called their "IP address space." Each AS is assigned an official number, or autonomous system number (ASN), similar to how every business has a business license with an unique, official number. An AS has to meet certain qualifications before the governing bodies that assign ASNs will give it a number. It must have a distinct routing policy, be of a certain size, and have more than one connection to other ASes. There is a limited amount of ASNs available, and if they were given out too freely, the supply would run out and routing would become much more complex. So, if our target meets these requirements, you can find their IP ranges by researching the ASN. 
[Hurricane Electric](https://bgp.he.net/) A great site to look up companies and find their ASN, along with IP ranges. As an example, let's take PepsiCo (Pepsi Cola) when I look it up we see the ASN is AS22460. Clicking on it you will see Prefixes v4, these are all the IPs associated with the ASN. \
Tip: You can highlight all the IPs here and copy them, even though it will have more than just IP addresses. Go to https://you.com/ (an AI) and type in this: "Show me only IP address ranges from (then paste in what you copied) This will output only the IP addresses. \
[ASNMAP](https://github.com/projectdiscovery/asnmap) Go CLI and Library for quickly mapping organization network ranges using ASN information. \
Install
```
go install github.com/projectdiscovery/asnmap/cmd/asnmap@latest
```
Example Usage
```
asnmap -a AS45596 -silent
```
```
asnmap -i 100.19.12.21 -silent
```
```
asnmap -d hackerone.com -silent
```
```
asnmap -org GOOGLE -silent
```
## Acquisitions
Supply Chain Compromise is a well known attack method, and while the main target may harden their defenses, the companies they have acquired may not hold the same security standard. If you can get in via one of these other companies, that is a win. 
[Crunchbase](https://www.crunchbase.com/) You can search for your target, then look at the Acquistions section. Now you have more websites that are potential targets. \
Tip: You can also go to the Wikipedia of the company and on the left under History you can also see Acquisitions.
## Subdomains
[BBOT](https://github.com/sh1katagana1/osint/blob/main/domain-osint.md#bbot)

