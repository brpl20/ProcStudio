[Back](../README.md)

# Draft

Criar um registro sem registro prévio:
```
  {
    "draftable_type": "Work",
    "draftable_id": null,
    "form_type": "work_creation",
    "session_id": "abc",
    "data": {
      "note": "Draft note for work",
      "folder": "Draft folder",
      "initial_atendee": 5,
      "lawsuit": true
    }
  }
``



  {
    "draftable_type": "Work",
    "draftable_id": 1,
        # Id do Work que estamos salvando (para edições)
        # Id será único para novos registros
    "form_type": "work_edit",
    "data": {
      "note": "Draft note for work",
      "folder": "Draft folder",
      "initial_atendee": 5,
      "lawsuit": true
    }
  }
