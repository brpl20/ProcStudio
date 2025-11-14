# frozen_string_literal: true

module Referrals
  module Mail
    class ReferralEmailService < ApplicationService
      include Customers::Mail::MailjetService

      def initialize(referral, referral_url)
        @referral = referral
        @referral_url = referral_url
      end

      private

      attr_reader :referral, :referral_url

      def referrer_name
        @referrer_name ||= referral.referred_by.user_profile&.full_name || 'Um amigo'
      end

      def to
        [{ Email: referral.email, Name: referral.email.split('@').first.capitalize }]
      end

      def subject
        "#{referrer_name} indicou você para o Procstudio - Ganhe 1 mês grátis!"
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
              .benefits {
                background-color: #f0f9ff;
                border-left: 4px solid #2563eb;
                padding: 20px;
                margin: 20px 0;
                border-radius: 4px;
              }
              .benefit-item {
                margin: 10px 0;
                padding-left: 24px;
                position: relative;
              }
              .benefit-item:before {
                content: "✓";
                position: absolute;
                left: 0;
                color: #2563eb;
                font-weight: bold;
              }
              .footer {
                margin-top: 40px;
                padding-top: 20px;
                border-top: 1px solid #e5e7eb;
                font-size: 14px;
                color: #6b7280;
                text-align: center;
              }
              .reward {
                background-color: #fef3c7;
                border: 2px solid #f59e0b;
                padding: 16px;
                border-radius: 6px;
                text-align: center;
                margin: 20px 0;
              }
              .reward-text {
                color: #d97706;
                font-weight: bold;
                font-size: 18px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <div class="logo">Procstudio</div>
              </div>

              <div class="content">
                <h2>#{referrer_name} indicou você!</h2>

                <p>Olá!</p>

                <p><strong>#{referrer_name}</strong> está usando o Procstudio para gerenciar processos jurídicos e achou que você também poderia se beneficiar!</p>

                <div class="reward">
                  <p class="reward-text">🎁 Oferta Especial: Ganhe #{referrer_name} também ganha!</p>
                  <p style="margin: 8px 0 0 0; color: #78350f;">Quando você assinar o plano Pro, #{referrer_name} ganha 1 mês grátis como agradecimento!</p>
                </div>

                <div class="benefits">
                  <p style="margin: 0 0 12px 0;"><strong>Por que usar o Procstudio?</strong></p>
                  <div class="benefit-item">Gestão completa de processos jurídicos</div>
                  <div class="benefit-item">Controle de clientes e documentos</div>
                  <div class="benefit-item">Geração automática de documentos</div>
                  <div class="benefit-item">Acompanhamento de prazos e tarefas</div>
                  <div class="benefit-item">Relatórios e dashboards intuitivos</div>
                </div>

                <p><strong>Comece agora gratuitamente!</strong></p>

                <div style="text-align: center;">
                  <a href="#{referral_url}" class="button">Criar Minha Conta Grátis</a>
                </div>

                <p style="font-size: 14px; color: #6b7280;">Ou copie e cole este link no seu navegador:</p>
                <p style="font-size: 13px; color: #9ca3af; word-break: break-all;">#{referral_url}</p>

                <p style="margin-top: 20px;"><strong>Planos disponíveis:</strong></p>
                <ul>
                  <li><strong>Basic (Grátis):</strong> Até 100 clientes, 150 processos, 100 trabalhos</li>
                  <li><strong>Pro (R$ 70/mês):</strong> Clientes e processos ilimitados, mais recursos avançados</li>
                </ul>

                <p style="font-size: 14px; color: #ef4444;">⏰ Esta indicação expira em #{referral.days_until_expiration} dias.</p>
              </div>

              <div class="footer">
                <p>Esta indicação foi enviada por #{referrer_name}. Se você não esperava este convite, pode ignorar este e-mail.</p>
                <p style="margin-top: 10px;">&copy; #{Time.current.year} Procstudio. Todos os direitos reservados.</p>
              </div>
            </div>
          </body>
          </html>
        HTML
      end

      def text_body
        <<~TEXT
          PROCSTUDIO - INDICAÇÃO ESPECIAL

          Olá!

          #{referrer_name} indicou você para o Procstudio!

          🎁 OFERTA ESPECIAL
          Quando você assinar o plano Pro, #{referrer_name} ganha 1 mês grátis como agradecimento pela indicação!

          POR QUE USAR O PROCSTUDIO?
          ✓ Gestão completa de processos jurídicos
          ✓ Controle de clientes e documentos
          ✓ Geração automática de documentos
          ✓ Acompanhamento de prazos e tarefas
          ✓ Relatórios e dashboards intuitivos

          PLANOS DISPONÍVEIS:
          - Basic (Grátis): Até 100 clientes, 150 processos, 100 trabalhos
          - Pro (R$ 70/mês): Clientes e processos ilimitados

          CRIE SUA CONTA:
          #{referral_url}

          ⏰ Esta indicação expira em #{referral.days_until_expiration} dias.

          ---
          Esta indicação foi enviada por #{referrer_name}.
          Se você não esperava este convite, pode ignorar este e-mail.

          © #{Time.current.year} Procstudio. Todos os direitos reservados.
        TEXT
      end
    end
  end
end
