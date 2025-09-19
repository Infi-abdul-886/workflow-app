from rest_framework import permissions
from django.db.models import Q

class IsWorkflowOwnerOrShared(permissions.BasePermission):
    """
    Permission to only allow owners or shared users to access workflows
    """
    
    def has_object_permission(self, request, view, obj):
        # Check if user is owner or workflow is shared with them
        return (
            obj.created_by == request.user or 
            obj.shared_with.filter(id=request.user.id).exists()
        )

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Permission to only allow owners to edit objects
    """
    
    def has_object_permission(self, request, view, obj):
        # Read permissions for any authenticated user
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions only for owner
        return obj.created_by == request.user

class CanExecuteWorkflow(permissions.BasePermission):
    """
    Permission to check if user can execute a workflow
    """
    
    def has_object_permission(self, request, view, obj):
        # User can execute if they own it or it's shared with them
        return (
            obj.created_by == request.user or 
            obj.shared_with.filter(id=request.user.id).exists()
        )
