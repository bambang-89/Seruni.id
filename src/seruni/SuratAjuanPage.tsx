/**
 * Surat Ajuan Form Page
 * Wraps SuratAjuanForm in EditorialLayout.
 */
import { EditorialLayout, SectionWrap } from "./ui";
import { SuratAjuanForm } from "./components/SuratAjuanForm";
import { Seo } from "./lib/seo";

export default function SuratAjuanPage() {
  return (
    <EditorialLayout
        
      >
      
      <SectionWrap>
        <SuratAjuanForm />
      </SectionWrap>
    </EditorialLayout>
  );
}
