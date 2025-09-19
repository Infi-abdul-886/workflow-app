"""system URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from rest_framework_simplejwt import views as jwt_views
from django.conf.urls import include

from system.views.log import log_view
from system.views.login import  web_app_login, web_app_logout, session_check, \
    forgot_password, verify_reset_link, reset_password

# only for development, todo: for production use nginx to serve the uploaded files
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('createtoken/', jwt_views.TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('refreshtoken/', jwt_views.TokenRefreshView.as_view(), name='token_refresh'),
    path('generatekey/',include("apps.key_creation.urls")),
    # path('getjwtusingtoken/', TokenObtainPairViewWithWebAppToken.as_view(),
        #  name='get_jwt'),
    path("web_app_login/",web_app_login),
    path("log/", log_view),
    path("web_app_logout/", web_app_logout),
    path("checksession/", session_check),
    #forgotpassword
    path("forgotpassword/", forgot_password),
    path("reset_link/", verify_reset_link),
    path("resetpassword/", reset_password),
    # reschedule endpoints
    path("menu/", include('apps.menu.urls')),
    path('test/', include('apps.test.urls')),
    path('cronjob/', include('apps.cronjob.urls')),
    path("query-builder/", include("apps.query_builder.urls")),
    path('', include('apps.workflow_app.urls')), # Include your app's URLs
    path("query/", include("apps.query.urls")),
    

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
# if debug is true,enabling docs,debug tool bar,etc...
if settings.DEBUG:
    urlpatterns = urlpatterns + [
        # Api schema related endpoints
        path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
        # Optional UI:
        path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
        path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
        # debug toolbar to analyse sql ,cpu performance...etc
        path('__debug__/', include('debug_toolbar.urls')),
    ]
