# 🚀 Archon Production Deployment Guide

This guide will walk you through deploying your Archon application to production for the first time.

## 📋 Prerequisites

Before deploying, ensure you have:
- ✅ The application running locally (which you do!)
- ✅ A Supabase account with your database set up (which you have!)
- 💳 A credit/debit card for cloud hosting services (most offer free tiers)
- 🌐 (Optional) A domain name for your application

## 🎯 Recommended Deployment Options (Beginner-Friendly)

### Option 1: Railway (Easiest for Beginners) ⭐
**Cost**: ~$5-20/month (with $5 free credit to start)
**Pros**: Super easy, automatic deployments, handles Docker well
**Best for**: Quick deployment without much configuration

### Option 2: DigitalOcean App Platform 
**Cost**: ~$12-25/month (with $200 free credit for 60 days)
**Pros**: Good Docker support, simple interface
**Best for**: More control with reasonable simplicity

### Option 3: Render
**Cost**: Free tier available, ~$7-25/month for paid
**Pros**: Good free tier, automatic SSL
**Best for**: Testing and small projects

### Option 4: VPS (DigitalOcean Droplet, AWS EC2, etc.)
**Cost**: ~$6-20/month
**Pros**: Full control, most flexible
**Best for**: Those comfortable with Linux command line

## 🚀 Step-by-Step Deployment (Railway - Recommended for First-Time)

### Step 1: Fork the Repository

```bash
# 1. Go to https://github.com/coleam00/Archon
# 2. Click "Fork" button in top-right
# 3. This creates your own copy

# 4. Update your local repository to point to your fork:
git remote set-url origin https://github.com/YOUR_USERNAME/Archon.git

# 5. Push your current state:
git push -u origin main
```

### Step 2: Create Production Environment File

Create a `.env.production` file (DO NOT commit this!):

```env
# Supabase (same as your local)
SUPABASE_URL=https://ypjffkganqnkgaqskggy.supabase.co
SUPABASE_SERVICE_KEY=your_service_key_here

# Production URLs (update after deployment)
VITE_API_BASE_URL=https://your-app-name.up.railway.app
PUBLIC_API_URL=https://your-app-name.up.railway.app
CORS_ORIGINS=https://your-app-name.up.railway.app

# Keep these the same
MCP_SERVER_PORT=8051
SERVER_PORT=8181
FRONTEND_PORT=3737

# Optional Production Settings
NODE_ENV=production
LOG_LEVEL=info
```

### Step 3: Deploy to Railway

1. **Sign up at Railway**:
   - Go to https://railway.app
   - Sign up with GitHub
   - Authorize Railway to access your repositories

2. **Create New Project**:
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your forked Archon repository
   - Railway will automatically detect it's a Docker project

3. **Configure Environment Variables**:
   - In Railway dashboard, go to your project
   - Click on the service → Variables tab
   - Add all variables from your `.env.production`:
     - `SUPABASE_URL`
     - `SUPABASE_SERVICE_KEY`
     - All other environment variables

4. **Configure Services**:
   Railway should create services for each container. If not:
   - Click "New" → "Empty Service" for each:
     - archon-server
     - archon-mcp
     - archon-frontend

5. **Set Service Settings**:
   For each service, configure:
   - **archon-server**: 
     - Port: 8181
     - Health check path: /health
   - **archon-mcp**: 
     - Port: 8051
   - **archon-frontend**: 
     - Port: 3737
     - Generate domain (click "Generate Domain" in settings)

6. **Deploy**:
   - Railway will automatically build and deploy
   - Watch the logs for any errors
   - Your app will be live at the generated URL!

## 🔧 Alternative: VPS Deployment (DigitalOcean Droplet)

If you prefer more control, here's how to deploy on a VPS:

### Step 1: Create a Droplet

1. Sign up at https://digitalocean.com
2. Create a new Droplet:
   - Choose Ubuntu 22.04 LTS
   - Select at least 2GB RAM
   - Choose a datacenter near your users
   - Add SSH keys (or use password)

### Step 2: Initial Server Setup

```bash
# SSH into your server
ssh root@your_server_ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Create app directory
mkdir -p /var/www/archon
cd /var/www/archon
```

### Step 3: Deploy Your Application

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/Archon.git .

# Create production .env file
nano .env
# Paste your production environment variables

# Build and start containers
docker compose up -d

# Check if everything is running
docker compose ps
```

### Step 4: Setup Nginx Reverse Proxy

```bash
# Install Nginx
apt install nginx -y

# Create Nginx configuration
nano /etc/nginx/sites-available/archon

# Add this configuration:
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://localhost:3737;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # API
    location /api {
        proxy_pass http://localhost:8181;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Socket.IO
    location /socket.io/ {
        proxy_pass http://localhost:8181;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

```bash
# Enable the site
ln -s /etc/nginx/sites-available/archon /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### Step 5: Setup SSL with Let's Encrypt

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Get SSL certificate
certbot --nginx -d your-domain.com

# Auto-renewal is set up automatically
```

## 🔒 Security Checklist

Before going live:
- [ ] Change all default passwords
- [ ] Enable firewall (ufw on Ubuntu)
- [ ] Set up monitoring (UptimeRobot is free)
- [ ] Configure backups for your database
- [ ] Use environment variables for all secrets
- [ ] Enable HTTPS/SSL
- [ ] Set up error logging
- [ ] Configure rate limiting

## 📊 Monitoring Your Application

### Free Monitoring Options:
1. **UptimeRobot** (https://uptimerobot.com) - Free uptime monitoring
2. **Supabase Dashboard** - Monitor database usage
3. **Railway/Render Metrics** - Built-in platform metrics
4. **Docker logs**: `docker compose logs -f`

## 🆘 Troubleshooting Common Issues

### Container Won't Start
```bash
# Check logs
docker compose logs archon-server
docker compose logs archon-mcp
docker compose logs archon-ui

# Restart containers
docker compose restart
```

### Database Connection Issues
- Verify SUPABASE_URL and SUPABASE_SERVICE_KEY are correct
- Check Supabase dashboard for any issues
- Ensure your server IP is not blocked by Supabase

### Frontend Can't Connect to Backend
- Check CORS_ORIGINS environment variable
- Verify all services are running: `docker compose ps`
- Check Nginx configuration if using reverse proxy

## 📝 Post-Deployment Tasks

1. **Test Everything**:
   - Visit your domain
   - Test all features
   - Check WebSocket connections
   - Verify database operations

2. **Set Up Backups**:
   - Supabase handles database backups
   - Consider backing up your server configuration

3. **Configure Domain** (if you have one):
   - Add A record pointing to your server IP
   - Configure www subdomain if needed

4. **Monitor Performance**:
   - Set up alerts for downtime
   - Monitor resource usage
   - Check error logs regularly

## 🎉 Congratulations!

Your Archon application is now deployed to production! 

### Need Help?
- Railway Discord: https://discord.gg/railway
- DigitalOcean Community: https://www.digitalocean.com/community
- Supabase Discord: https://discord.supabase.com

### Next Steps:
1. Share your application URL with users
2. Set up a custom domain
3. Implement CI/CD for automatic deployments
4. Scale as your user base grows

Remember: Start small, monitor everything, and scale gradually!