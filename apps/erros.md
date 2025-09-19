/var/www/html/grouprm/GRM$ python manage.py makemigrations workflow_app
/var/www/html/grouprm/GRM/venv/lib/python3.8/site-packages/django/db/models/base.py:321: RuntimeWarning: Model 'system.query' was already registered. Reloading models is not advised as it can lead to inconsistencies, most notably with related models.
  new_class._meta.apps.register_model(new_class._meta.app_label, new_class)
/var/www/html/grouprm/GRM/venv/lib/python3.8/site-packages/django/db/models/base.py:321: RuntimeWarning: Model 'system.log' was already registered. Reloading models is not advised as it can lead to inconsistencies, most notably with related models.
  new_class._meta.apps.register_model(new_class._meta.app_label, new_class)
Migrations for 'workflow_app':
  apps/workflow_app/migrations/0001_initial.py
    - Create model WorkflowSharedWith
    - Create model NodeType
    - Create model Workflow
    - Create model WorkflowTemplate
    - Create model WorkflowWebhook
    - Create model WorkflowVariable
    - Create model WorkflowSchedule
    - Create model WorkflowExecution
    - Create model NodeExecution
    - Create index workflow_ap_endpoin_2d2827_idx on field(s) endpoint_path, is_active of model workflowwebhook
    - Create index workflow_ap_scope_a00e44_idx on field(s) scope, name of model workflowvariable
    - Alter unique_together for workflowvariable (1 constraint(s))
    - Create index workflow_ap_workflo_d07f32_idx on field(s) workflow, status of model workflowexecution
    - Create index workflow_ap_status_21a699_idx on field(s) status, started_at of model workflowexecution
    - Create index workflow_ap_created_82a1ed_idx on field(s) created_by_id, status of model workflow
    - Create index workflow_ap_status_2bd3db_idx on field(s) status, is_scheduled of model workflow
    - Create index workflow_ap_workflo_5b6f26_idx on field(s) workflow_execution, status of model nodeexecution
    - Create index workflow_ap_node_id_17c9d9_idx on field(s) node_id, workflow_execution of model nodeexecution
(venv) abdulsalam.m@ISS-L-126:/var/www/html/grouprm/GRM$ python3 manage.py check
/var/www/html/grouprm/GRM/venv/lib/python3.8/site-packages/django/db/models/base.py:321: RuntimeWarning: Model 'system.query' was already registered. Reloading models is not advised as it can lead to inconsistencies, most notably with related models.
  new_class._meta.apps.register_model(new_class._meta.app_label, new_class)
/var/www/html/grouprm/GRM/venv/lib/python3.8/site-packages/django/db/models/base.py:321: RuntimeWarning: Model 'system.log' was already registered. Reloading models is not advised as it can lead to inconsistencies, most notably with related models.
  new_class._meta.apps.register_model(new_class._meta.app_label, new_class)
System check identified no issues (0 silenced).
(venv) abdulsalam.m@ISS-L-126:/var/www/html/grouprm/GRM$ 
