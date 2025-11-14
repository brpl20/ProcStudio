# frozen_string_literal: true

module Users
  module Mail
    class InvitationService < ApplicationService
      include Customers::Mail::MailjetService

      def initialize(invitation, invitation_url)
        @invitation = invitation
        @invitation_url = invitation_url
      end

      private

      attr_reader :invitation, :invitation_url

      def inviter_name
        @inviter_name ||= invitation.invited_by.user_profile&.full_name || 'Um colega'
      end

      def team_name
        @team_name ||= invitation.team.name
      end

      def to
        [{ Email: invitation.email, Name: invitation.email.split('@').first.capitalize }]
      end

      def subject
        "#{inviter_name} convidou você para o Procstudio"
      end

      def message
        {
          From: from,
          To: to,
          Subject: subject,
          HTMLPart: html_body,
          TextPart: text_body
        }
      end

      def html_body
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
              }
              .container {
                background-color: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                padding: 40px;
              }
              .header {
                text-align: center;
                margin-bottom: 30px;
              }
              .logo {
                font-size: 28px;
                font-weight: bold;
                color: #2563eb;
              }
              .content {
                margin-bottom: 30px;
              }
              .button {
                display: inline-block;
                padding: 14px 32px;
                background-color: #2563eb;
                color: #ffffff !important;
                text-decoration: none;
                border-radius: 6px;
                font-weight: 600;
                text-align: center;
                margin: 20px 0;
              }
              .button:hover {
                background-color: #1d4ed8;
              }
              .info-box {
                background-color: #f3f4f6;
                border-left: 4px solid #2563eb;
                padding: 16px;
                margin: 20px 0;
                border-radius: 4px;
              }
              .footer {
                margin-top: 40px;
                padding-top: 20px;
                border-top: 1px solid #e5e7eb;
                font-size: 14px;
                color: #6b7280;
                text-align: center;
              }
              .expiration {
                color: #ef4444;
                font-weight: 600;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <div class="logo">Procstudio</div>
              </div>

              <div class="content">
                <h2>Você foi convidado!</h2>

                <p>Olá!</p>

                <p><strong>#{inviter_name}</strong> convidou você para se juntar ao time <strong>#{team_name}</strong> no Procstudio.</p>

                <div class="info-box">
                  <p style="margin: 0;"><strong>O que é o Procstudio?</strong></p>
                  <p style="margin: 8px 0 0 0;">Procstudio é uma plataforma completa de gestão jurídica que facilita o gerenciamento de processos, clientes e equipes.</p>
                </div>

                <p>Para aceitar o convite e criar sua conta, clique no botão abaixo:</p>

                <div style="text-align: center;">
                  <a href="#{invitation_url}" class="button">Aceitar Convite</a>
                </div>

                <p style="font-size: 14px; color: #6b7280;">Ou copie e cole este link no seu navegador:</p>
                <p style="font-size: 13px; color: #9ca3af; word-break: break-all;">#{invitation_url}</p>

                <p class="expiration">⏰ Este convite expira em #{invitation.days_until_expiration} dias.</p>
              </div>

              <div class="footer">
                <p>Se você não esperava este convite, pode ignorar este e-mail.</p>
                <p style="margin-top: 10px;">&copy; #{Time.current.year} Procstudio. Todos os direitos reservados.</p>
              </div>
            </div>
          </body>
          </html>
        HTML
      end

      def text_body
        <<~TEXT
          PROCSTUDIO - CONVITE DE EQUIPE

          Olá!

          #{inviter_name} convidou você para se juntar ao time #{team_name} no Procstudio.

          O que é o Procstudio?
          Procstudio é uma plataforma completa de gestão jurídica que facilita o gerenciamento de processos, clientes e equipes.

          Para aceitar o convite e criar sua conta, acesse:
          #{invitation_url}

          ⏰ Este convite expira em #{invitation.days_until_expiration} dias.

          Se você não esperava este convite, pode ignorar este e-mail.

          ---
          © #{Time.current.year} Procstudio. Todos os direitos reservados.
        TEXT
      end
    end
  end
end
