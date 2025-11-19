[Voltar](../README.md)

# Integração entre Frontend e Backend -> Aws S3
Por favor leia atentamente a implementação do [backend](./s3-backend.md) antes de começar a leitura deste manual de integração.

## Endpoints Específicos
- Office Logo Upload => `POST offices/:id/upload_logo`
- Office Social Contracts Upload => `POST offices/:id/upload_contracts`
- User Profile Avatar Upload => `POST user_profiles/:id/upload_avatar`

## Endpoints Genéricos
- Office: `POST offices/:id/upload_attachment`
- UserProfile: `POST user_profiles/:id/upload_attachment`
- Job: `POST jobs/:id/upload_attachment`
- Work: `POST works/:id/upload_attachment`
- Customer: `POST profile_customers/:id/upload_attachment`

## Endpoints de Deletação
- All: `DELETE /api/v1/{resource}/:id/attachments/:attachment_id`

## Endpoints de Transferência

### Transferência Global
For transferring attachments when you only have the attachment ID:
- `POST /api/v1/attachments/:id/transfer`

### Trasnferência Específica
- `POST /api/v1/offices/:id/attachments/:attachment_id/transfer`
- `POST /api/v1/user_profiles/:id/attachments/:attachment_id/transfer`
- `POST /api/v1/jobs/:id/attachments/:attachment_id/transfer`
- `POST /api/v1/works/:id/attachments/:attachment_id/transfer`
- `POST /api/v1/profile_customers/:id/attachments/:attachment_id/transfer`

### Request
```json
{
  "to_type": "Work",           // Target model type (required)
  "to_id": 456,                // Target model ID (required)
  "reason": "Reassigning to correct work", // Optional transfer reason
  "reorganize_s3": true,       // Optional: Move file in S3 to new path
  "validate_compatibility": true // Optional: Validate file type compatibility
}
```


### Transfer Validations

The system validates:
1. **Authorization**: User must have update permissions on both source and target models
2. **File type compatibility**:
   - Avatar files can only be transferred to UserProfiles
   - Logo files can only be transferred to Offices
   - Social contracts can only be transferred to Offices
3. **Model support**: Target model must support attachments
4. **Same-model prevention**: Cannot transfer to the same model instance

### Transfer Metadata

Transfers are tracked in the FileMetadata record:
- `transferred_at`: Timestamp of the transfer
- `transferred_by_id`: UserProfile ID who performed the transfer
- `transfer_metadata`: JSON containing transfer history and reason

### S3 Path Reorganization

When `reorganize_s3: true` is set:
1. The file is copied to a new S3 path based on the target model
2. The original file is deleted from S3
3. The FileMetadata record is updated with the new S3 key

This maintains an organized S3 structure where files are grouped by their owning model.
