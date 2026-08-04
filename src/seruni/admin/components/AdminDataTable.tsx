import React from "react";

interface Column<T> {
  header: string;
  accessor: (row: T) => React.ReactNode;
  className?: string;
}

interface AdminDataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  isLoading?: boolean;
  emptyMessage?: string;
  keyExtractor: (row: T) => string;
}

export function AdminDataTable<T>({
  columns,
  data,
  isLoading,
  emptyMessage = "Belum ada data.",
  keyExtractor,
}: AdminDataTableProps<T>) {
  return (
    <div className="overflow-x-auto rounded-xl bg-card border border-border shadow-sm">
      <table className="w-full text-sm">
        <thead className="bg-muted/50 border-b border-border">
          <tr>
            {columns.map((col, i) => (
              <th key={i} className={`text-left px-4 py-3 font-semibold text-muted-foreground ${col.className || ""}`}>
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {isLoading && (
            <tr>
              <td colSpan={columns.length} className="px-4 py-8 text-center text-muted-foreground animate-pulse">
                Memuat data...
              </td>
            </tr>
          )}
          {!isLoading && data.length === 0 && (
            <tr>
              <td colSpan={columns.length} className="px-4 py-12 text-center text-muted-foreground">
                <div className="flex flex-col items-center justify-center space-y-3">
                  <div className="bg-muted p-3 rounded-full">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="opacity-50"><rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><line x1="3" x2="21" y1="9" y2="9"/><line x1="9" x2="9" y1="21" y2="9"/></svg>
                  </div>
                  <p>{emptyMessage}</p>
                </div>
              </td>
            </tr>
          )}
          {!isLoading && data.map((row) => (
            <tr key={keyExtractor(row)} className="hover:bg-muted/30 transition-colors">
              {columns.map((col, i) => (
                <td key={i} className={`px-4 py-3 ${col.className || ""}`}>
                  {col.accessor(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
