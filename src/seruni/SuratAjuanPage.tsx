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
      eyebrow="Layanan"
      judul="Ajukan Surat"
      deskripsi="Isi formulir pengajuan surat secara online."
      crumbs={[
        { label: "Beranda", to: "/" },
        { label: "Layanan", to: "/layanan" },
        { label: "Surat", to: "/layanan/surat" },
        { label: "Ajukan" },
      ]}
    >
      <Seo
        title="Ajukan Surat Online"
        description="Formulir pengajuan surat keterangan online untuk warga Desa Seruni Mumbul."
        path="/layanan/surat/ajuan"
      />
      <SectionWrap>
        <SuratAjuanForm />
      </SectionWrap>
    </EditorialLayout>
  );
}
