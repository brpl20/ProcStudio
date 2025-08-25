<script>
  import { WebsiteName } from '../config.js';
  const currentYear = new Date().getFullYear();
</script>

<footer class="footer footer-center p-10 bg-base-200 text-base-content">
  <div class="grid grid-flow-col gap-4">
    <a href="/about" class="link link-hover">Sobre</a>
    <a href="/contact" class="link link-hover">Contato</a>
    <a href="/privacy" class="link link-hover">Privacidade</a>
    <a href="/terms" class="link link-hover">Termos</a>
  </div>
  <div>
    <p>© {currentYear} {WebsiteName}. Todos os direitos reservados.</p>
  </div>
</footer>