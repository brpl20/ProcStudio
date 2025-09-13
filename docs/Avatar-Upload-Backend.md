# Documentação do Sistema de Upload de Avatar - Backend

## Visão Geral

O sistema de upload de avatar permite que usuários enviem e gerenciem suas fotos de perfil através da API. O sistema utiliza o Active Storage do Rails para gerenciar os arquivos de imagem.

## Estrutura do Sistema

### Modelo UserProfile

O modelo `UserProfile` possui o attachment para avatar:

```ruby
class UserProfile < ApplicationRecord
  include AvatarUrlConcern
  
  has_one_attached :avatar
  
  # ... outros códigos
end
```

### Concern AvatarUrlConcern

Localizado em `app/models/concerns/avatar_url_concern.rb`, fornece o método `avatar_url`:

```ruby
module AvatarUrlConcern
  extend ActiveSupport::Concern

  def avatar_url(only_path: true)
    return nil unless avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: only_path)
  rescue StandardError
    nil
  end
end
```

### Controller UserProfilesController

O controller permite upload de avatar através dos parâmetros permitidos:

```ruby
def user_profiles_params
  params.require(:user_profile).permit(
    :role, :status, :user_id, :office_id, :name, :last_name, :gender, :oab,
    :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :origin, :avatar,
    # ... outros parâmetros
  )
end
```

## Endpoints da API

### POST /api/v1/user_profiles (Criar perfil com avatar)

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Body (form-data):**
```
user_profile[name]: Nome do usuário
user_profile[avatar]: [FILE] arquivo de imagem
user_profile[user_attributes][email]: email@exemplo.com
user_profile[user_attributes][password]: senha123
user_profile[user_attributes][password_confirmation]: senha123
```

**Resposta de Sucesso (201):**
```json
{
  "success": true,
  "message": "Perfil de usuário criado com sucesso",
  "data": {
    "id": "1",
    "type": "user_profile",
    "attributes": {
      "id": 1,
      "name": "Nome do usuário",
      "avatar_url": "/rails/active_storage/blobs/redirect/..."
    }
  }
}
```

### PUT/PATCH /api/v1/user_profiles/:id (Atualizar avatar)

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Body (form-data):**
```
user_profile[avatar]: [FILE] novo arquivo de imagem
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Perfil de usuário atualizado com sucesso",
  "data": {
    "id": "1",
    "type": "user_profile",
    "attributes": {
      "id": 1,
      "name": "Nome do usuário",
      "avatar_url": "/rails/active_storage/blobs/redirect/..."
    }
  }
}
```

## Formatos de Arquivo Suportados

O Active Storage aceita diversos formatos de imagem:
- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- WebP (.webp)
- BMP (.bmp)

## Validações e Limitações

### Tamanho do Arquivo
- Não há validação específica de tamanho implementada no modelo
- Limitações podem ser configuradas no servidor web (Nginx/Apache)

### Tipo de Arquivo
- Active Storage aceita qualquer tipo de arquivo
- Recomenda-se implementar validações customizadas se necessário

## Exemplo de Validação Customizada (Opcional)

Para adicionar validações de tipo e tamanho:

```ruby
class UserProfile < ApplicationRecord
  has_one_attached :avatar
  
  validate :avatar_validation
  
  private
  
  def avatar_validation
    return unless avatar.attached?
    
    # Validar tipo de arquivo
    unless avatar.blob.content_type.in?(['image/jpeg', 'image/png', 'image/gif'])
      errors.add(:avatar, 'deve ser uma imagem JPEG, PNG ou GIF')
    end
    
    # Validar tamanho (5MB)
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, 'deve ter no máximo 5MB')
    end
  end
end
```

## Service para Attachments Externos

O sistema inclui um service para anexar avatares de URLs externas:

### LegalData::AvatarAttachmentService

Localizado em `app/services/legal_data/avatar_attachment_service.rb`, permite anexar avatares de:
- URLs HTTP/HTTPS
- URLs do Amazon S3

**Uso:**
```ruby
service = LegalData::AvatarAttachmentService.new
service.attach_from_url(user_profile, 'https://exemplo.com/imagem.jpg')
```

## Acesso ao Avatar

### No Serializer
```ruby
def avatar_url
  object.avatar_url(only_path: false) if object.avatar.attached?
end
```

### No Frontend
```javascript
// URL completa do avatar
const avatarUrl = userProfile.avatar_url;

// Exibir em uma tag img
<img src={avatarUrl} alt="Avatar do usuário" />
```

## Considerações de Performance

1. **Lazy Loading**: Active Storage carrega attachments sob demanda
2. **CDN**: Configure um CDN para servir os arquivos estáticos
3. **Variantes**: Use variants para diferentes tamanhos de imagem:

```ruby
# Exemplo de variante
user_profile.avatar.variant(resize_to_limit: [100, 100])
```

## Troubleshooting

### Avatar não aparece
1. Verificar se o arquivo foi anexado: `user_profile.avatar.attached?`
2. Verificar permissões do Active Storage
3. Verificar configurações do S3 (se usado)

### Erro de upload
1. Verificar Content-Type na requisição
2. Verificar tamanho do arquivo
3. Verificar logs do Rails para detalhes do erro

### URLs quebradas
1. Verificar configuração do `config.active_storage.variant_processor`
2. Verificar se o ImageMagick ou libvips está instalado
3. Verificar configurações de storage (disk/S3)