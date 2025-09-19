# GRM Project Structure and Framework Documentation

## Project Directory Structure
```
/var/www/html/GRM/
├── apps/                      # Main applications folder
│   ├── cronjob/              # Handles scheduled tasks and PNR updates
│   │   ├── classes/          # Core business logic classes
│   │   ├── views/           # View handlers
│   │   └── migrations/      # Database migrations
│   ├── key_creation/         # Key management functionality
│   ├── menu/                 # Menu and navigation
│   │   ├── serializers/     # API serializers
│   │   ├── signals/        # Django signals
│   │   └── views/          # View handlers
│   ├── query/               # Query handling and templates
│   │   └── templates/      # Query-related templates
│   ├── query_builder/       # Advanced query building
│   │   ├── services/       # Business services
│   │   └── templates/      # Query builder templates
│   ├── shared/             # Shared components
│   │   └── models/         # Shared models
│   ├── test1/              # Test application
│   └── workflow_app/       # Workflow automation
│       ├── management/     # Management commands
│       ├── templates/      # Workflow templates
│       └── templatetags/   # Custom template tags
├── Docker/                 # Docker configuration
│   ├── Dockerfile         # Container definition
│   ├── requirements.txt   # Python dependencies
│   └── uwsgi.yml         # uWSGI configuration
├── media/                 # Media files storage
│   └── email_api/        # Email-related media
├── system/               # Core system configuration
│   ├── forms/           # Form definitions
│   ├── keys/            # Security keys
│   ├── log/            # System logs
│   ├── middleware/     # Custom middleware
│   ├── migrations/     # System migrations
│   ├── schema/         # API schema definitions
│   ├── settings/       # Django settings
│   ├── templates/      # System templates
│   ├── utils/         # Utility functions
│   └── views/         # Core views
└── manage.py          # Django management script

## Framework Components

### 1. Database Configuration
- Engine: MySQL
- Custom User Model: `system.User`
- UUID Primary Keys
- Foreign Key Relationships with Custom Constraints

### 2. Installed Applications
```python
INSTALLED_APPS = [
    'corsheaders',
    'django_crontab',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'whitenoise.runserver_nostatic',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework.authtoken',
    'django_filters',
    'drf_spectacular',
    'debug_toolbar',
    'django_admin_listfilter_dropdown',
    'system',
    'apps.key_creation',
    'apps.menu',
    'apps.shared',
    'apps.test1',
    'django_celery_beat',
    'django_celery_results',
    'apps.cronjob',
    'apps.workflow_app'
]
```

### 3. Middleware Configuration
```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'debug_toolbar.middleware.DebugToolbarMiddleware',
]
```

### 4. Key Features

#### Authentication & Security
- Custom User Authentication
- Token-based Authentication
- JWT Support
- CSRF Protection
- Custom Security Middleware

#### API Features
- REST Framework Integration
- Custom Serializers
- API Routing
- Cross-domain Support
- OpenAPI Schema Support

#### Task Processing
- Celery Integration
- Cron Job Scheduling
- Background Task Processing
- Task Queue Management

#### Development Tools
- Docker Containerization
- Debug Toolbar
- Whitenoise Static Files
- CORS Handling
- Development/Production Settings

### 5. Application Details

#### workflow_app
- Workflow Management Models
- Task Scheduling
- Email Templates
- Webhook Integration
- Business Logic Engine

#### cronjob
- PNR Updates
- Passenger Management
- Payment Processing
- Transaction Handling

#### query_builder
- Custom Query Interface
- Database Query Execution
- Query Templates
- Advanced Filtering

#### menu
- Navigation Structure
- Menu Serialization
- Signal Handling
- Dynamic Menu Management

### 6. System Core Features

#### Settings Management
- Base Settings
- Development Configuration
- Production Configuration
- Cross-domain Settings

#### Middleware Components
- CSRF Token Handling
- HTTP Request Processing
- Logging Middleware
- Request Data Processing

#### Utility Functions
- Encryption Helpers
- Message Processing
- Threading Utilities
- Password Management

#### Template System
- Download Templates
- Error Pages
- Authentication Templates
- Custom Template Tags

## Development Workflow

1. **Local Development**
   - Use development settings
   - Debug toolbar enabled
   - Local database configuration

2. **Docker Development**
   - Containerized environment
   - uWSGI configuration
   - Volume mapping for development

3. **Production Deployment**
   - Production settings
   - Secure key management
   - Logging configuration
   - Cross-domain handling

## Additional Notes

- The project uses a modular structure with clear separation of concerns
- Each app has its own migrations, models, and views
- Shared components are centralized in the shared app
- System-level configurations are managed in the system directory
- Docker configuration provides consistent deployment environment
