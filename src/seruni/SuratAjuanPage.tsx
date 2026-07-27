/**
 * Surat Ajuan Form Page
 * Wraps SuratAjuanForm in EditorialLayout.
 */
import { StandaloneLayout } from "./ui";
import { SuratAjuanForm } from "./components/SuratAjuanForm";
import { Seo } from "./lib/seo";

export default function SuratAjuanPage() {
  return (
    <StandaloneLayout>
      <div className="max-w-2xl mx-auto py-8">
        <SuratAjuanForm />
      </div>
    </StandaloneLayout>
  );
}
