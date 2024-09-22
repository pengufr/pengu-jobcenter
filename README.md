# 🛠️ Pengu Job Center Script for Your QBCore Server

Elevate your QBCore server with the Pengu Job Center Script, designed to enhance job management, player engagement, and immersive gameplay.

## 📋 Dependencies
To ensure smooth functionality, please include the following dependencies in your server setup:

- **[qb-core](https://github.com/qbcore-framework/qb-core)**: The essential framework for your QBCore server.
- **[ox_lib](https://github.com/overextended/ox_lib)**: Provides extended functionality for your scripts.
- **[qb-target](https://github.com/qbcore-framework/qb-target)**: Enables targeting mechanics for interactions.
- **[qb-menu](https://github.com/qbcore-framework/qb-menu)**: A versatile menu system for user interactions.
- **[progressbar](https://github.com/qbcore-framework/progressbar)**: Adds progress bars for better visual feedback.

## 🔧 Optional Dependencies (fxmanifest.lua)
For additional features, consider these optional dependencies:

- **[ox_target](https://github.com/overextended/ox_target)**: A more advanced targeting system.
- **[qtarget](https://github.com/overextended/qtarget/releases)**: Another targeting option to enhance gameplay.

## 👀 Preview
- **[Preview] - Coming Soon!** Stay tuned for a visual showcase of the features!

## 🌟 Job Center Features
### Comprehensive Job Management:
- **Job Application System:** Players can easily apply for a variety of jobs, increasing engagement and role-play opportunities.
  
### Dynamic License Management:
- **Job License Management:** Automatically grants and manages job licenses upon acceptance, streamlining the hiring process.

### Duty Management:
- **Duty Toggle:** Players can toggle their duty status on or off, enhancing the realism of their in-game roles.

### Informative Job Listings:
- **Job Information Display:** Players can view essential details such as job name, starting rank, and salary when selecting a job.

### Progressive Rank System:
- **Job Rank Up System:** Players are promoted based on a configurable number of hours worked, rewarding dedication and playtime.

### Salary System:
- **Job Payment System:** As players rank up, their salaries increase, providing a sense of progression and reward.

### Persistent Progress Tracking:
- **Job Progress Saving:** Player progress is saved even if they disconnect, ensuring no loss of advancement toward promotions.

### Additional Features:
- **And Much More!** Explore the script to discover various functionalities tailored to enhance your server experience.

## 🚀 Installation Guide | Version 1.0.0

### Step 1: Import SQL
- Execute the SQL script located in `sql/jobcenter.sql` to set up the necessary database structures.

### Step 2: Update Items Configuration
- In your `qb-core/shared/items.lua`, add the following code snippet to define the job license item:

```lua
['license_name'] = { 
    ['name'] = 'license_name', 
    ['label'] = 'License Name', 
    ['weight'] = 50, 
    ['type'] = 'item', 
    ['image'] = 'license_name.png', 
    ['unique'] = true, 
    ['useable'] = false, 
    ['shouldClose'] = true, 
    ['combinable'] = nil, 
    ['description'] = 'Official license_name License' 
},
```
### Step 3: Update Inventory Configuration
- In your `qb-inventory/config.lua`, add the following code snippet to define the job license item: 

```lua
["license_name"] = {
    ["name"] = "license_name",
    ["label"] = "License Name",
    ["weight"] = 50,
    ["type"] = "item",
    ["image"] = "license_name.png",
    ["unique"] = true,
    ["useable"] = false,
    ["shouldClose"] = true,
    ["combinable"] = nil,
    ["description"] = "Official license_name License"
},
```

### ❓ Questions or Issues?
If you have any questions or encounter issues, feel free to reach out to me on **Discord: pengufr**. I'm here to help!
