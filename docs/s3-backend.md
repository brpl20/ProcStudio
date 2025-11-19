[Voltar](../README.md)

# Arquivos do Sistema e Aws S3

Para o armazenamento de arquivos no sistema nós utilizamos o [AWS S3](https://aws.amazon.com/s3/). O sistema Rail possui um sistema nativo chamado ActiveStorage que pode ser utilizado com o S3, porém optamos por NÃO utiliza-los, criando um serviço diratamente pelo S3.

# Estrutura central do Banco de Dados
Nós utilizamos uma tabela chamada `file_metadata` que é a centralizadora 'universal' dos arquivos, possuindo todas as informações de todos os arquivos, se você instanciar um objeto novo no Rails Console você terá os seguintes dados:

```ruby
- attachable (polymorphic)   # Can be Office, UserProfile, Job, Work, etc.
- s3_key                      # S3 path
- filename                    # Original filename
- content_type                # MIME type
- byte_size                   # File size in bytes
- checksum                    # SHA256 for deduplication
- created_by_system           # Boolean - true for system-generated files
- uploaded_by                 # UserProfile who uploaded
- file_category               # Type: logo, avatar, social_contract, etc.
- metadata                    # JSON hash with custom data
- uploaded_at                 # Timestamp of upload
- expires_at                  # Optional expiry date
```

Exemplo de arquivo criado:
```ruby
#<FileMetadata:0x0000000120b30dc8
 id: 18,
 attachable_type: "Office",
 attachable_id: 65,
 s3_key: "[FILTERED]",
 filename: "cs-unipessoal-drake-wilson.docx",
 content_type: "application/vnd.openxmlformats-officedocument.word...",
 byte_size: 16721,
 checksum: "115e92e9106111766be17944ca7b1adfaa4040676fd25777aa...",
 created_by_system: true,
 file_category: "social_contract",
 uploaded_by_id: 88,
 metadata:
  {"file_type"=>"social_contract", "description"=>"Contrato Social gerado automaticamente para Drake Wilson", "document_date"=>"2025-11-18"},
 uploaded_at: "2025-11-18 23:52:26.308329000 -0300",
 expires_at: nil,
 created_at: "2025-11-18 23:52:26.320852000 -0300",
 updated_at: "2025-11-18 23:52:26.320852000 -0300">
 ```

# Estrutura de armazenamento

```
bucket/
├── development/
│   └── team-31/
│       ├── offices/
│       │   └── 37/
│       │       ├── logo/
│       │       │   └── logo-20251117195134.jpg
│       │       └── social-contracts/
│       │           ├── contract-20251117194851-5b0ae3.pdf
│       │           └── contract-20251117195104-4d85f5.pdf
│       ├── user-profiles/
│       │   └── 61/
│       │       └── avatar/
│       │           └── avatar-20251117195136.jpg
│       ├── jobs/
│       │   └── 1/
│       │       └── attachment/
│       │           └── attachment-20251118-abc123.pdf
│       └── works/
│           └── 1/
│               └── procuration/
│                   └── procuration-20251118-def456.pdf
└── production/
    └── team-1/
        └── ...
```

A primeira divisão central é no env do ProcStudio:

```
bucket/development
bucket/staging
bucket/production
```

Depois ele é dividido em:
* Team-{id}
  * offices
  * user-profiles
  * jobs
  * works
  * ...

## Arquivos 'direcionados' e arquivos 'livres'
A grande divisão do sistema é que existem arquivos que ficarão vinculados a alguns modelos e outros arquivos que serão 'transeuntes' ou seja, poderão migrar de modelo para modelo, de lugar para lugar, o que permitirá uma mair flexibilidade do sistema.

### Arquivos Direcionados

#### Offices
- `/offices/{id}/logo`: Logo do escritório, que também estará na tabela do offices como: `logo_s3_key`
- `/offices/{id}/social_contracts`: Pasta em que se centralizam todos os contratos sociais, sejam feitos por upload sejam gerados pelo sistemais

#### UserProfile
- `/avatar_s3_key`: Avatar do usuário, que também estará na tabela do user_profiles como: `avatar_s3_key`


## S3 Manager Service
Para utilizar o S3 Manager Service, você precisa fazer o seguinte, vamos supor que você queira fazer o Upload de um documento gerado:

### Documento Gerado pelo Sistema:
1. Selecionar o arquivo que foi criado;
2. Usar o método: `ContractFileWrapper`;
3. Adicionar metadada: (document_date, description e outros campos capturados vão para o`metadata`)

```ruby
# In OfficesController#process_social_contract_generation
File.open(file_path, 'rb') do |file|
  # Create a wrapper for the generated DOCX file
  uploaded_file = ContractFileWrapper.new(file, file_path)

  # Upload with system_generated flag
  file_metadata = office.upload_social_contract(
    uploaded_file,
    user_profile: current_user.user_profile,
    system_generated: true,
    document_date: Date.current,
    description: "Contrato Social gerado automaticamente para #{office.name}"
  )
end
```

### Documento a partir de Upload do Usuário
```ruby
file_metadata = office.upload_social_contract(
  params[:contract],
  user_profile: current_user.user_profile,
  system_generated: false,  # User-uploaded file
  document_date: params[:document_date],
  description: params[:description]
)
```

## PathGenerator Module
O PathGenerator é o que vai determinar o caminho do arquivo na AWS S3, sempre considere a regra de caminhos préfixados e caminhos mais livres, dependendo do tipo do arquivo, a estrutura é a seguinte:

```
{environment}/team-{team_id}/{model_type}/{model_id}/{file_type}/{filename-timestamp-hash}.{ext}
```

Exemplos:
```
development/team-31/offices/37/logo/logo-20251117195134.png
development/team-31/offices/37/social-contracts/contract-20251118234648-abc123.docx
development/team-31/offices/37/social-contracts/contract-20251118234649-def456.pdf
```

1. Extrai a extensão do arquivo de upload (bem importante especialmente para os auto-gerados);


### S3CleanupJob
- Roda Diariamente as 2 da manhã
- Remove arquivos órfãos (ver como isso funciona melhor)
- Limpa arquivos expirados/temporários

### S3ChecksumJob
- Verifies file integrity
- Updates missing checksums
- Reports corrupted files

### S3MetricsJob
- Collects storage usage per team
- Tracks file types and sizes
- Generates usage reports

## Acessando Informações - Metadata
```ruby
office = Office.find(id)
metadata = office.logo

metadata.id
metadata.s3_key
metadata.filename
metadata.content_type
metadata.byte_size
metadata.checksum
metadata.created_by_system
metadata.uploaded_by
metadata.metadata
metadata.metadata['description']
metadata.metadata['document_date']
metadata.url
```

### Querying FileMetadata
```ruby
# system-generated files
FileMetadata.system_generated

# user-uploaded files
FileMetadata.user_uploaded

# by category
FileMetadata.by_category('social_contract')

# by uploader
FileMetadata.where(uploaded_by: user_profile)

# files for a specific model
FileMetadata.where(attachable: office)
```

## Testing (ToDo)
