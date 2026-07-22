import { Helmet } from "react-helmet-async";

const SITE_NAME = "Kantor Desa Seruni Mumbul";

export function Seo({
  title,
  description,
  path = "/",
  image,
  type = "website",
  jsonLd,
}: {
  title: string;
  description: string;
  path?: string;
  image?: string;
  type?: "website" | "article";
  jsonLd?: object;
}) {
  const fullTitle = title.includes(SITE_NAME) ? title : `${title} — ${SITE_NAME}`;
  return (
    <Helmet>
      <title>{fullTitle}</title>
      <meta name="description" content={description} />
      <link rel="canonical" href={path} />
      <meta property="og:title" content={fullTitle} />
      <meta property="og:description" content={description} />
      <meta property="og:type" content={type} />
      <meta property="og:url" content={path} />
      <meta property="og:site_name" content={SITE_NAME} />
      {image && <meta property="og:image" content={image} />}
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={fullTitle} />
      <meta name="twitter:description" content={description} />
      {image && <meta name="twitter:image" content={image} />}
      {jsonLd && (
        <script type="application/ld+json">{JSON.stringify(jsonLd)}</script>
      )}
    </Helmet>
  );
}