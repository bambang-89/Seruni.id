import React, { useState } from "react";
import { Input } from "@/components/ui/input";
import { X } from "lucide-react";

interface TagsInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}

export function TagsInput({ value, onChange, placeholder }: TagsInputProps) {
  const [inputValue, setInputValue] = useState("");
  
  const tags = value ? value.split(",").map(t => t.trim()).filter(Boolean) : [];

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" || e.key === ",") {
      e.preventDefault();
      const newTag = inputValue.trim();
      if (newTag && !tags.includes(newTag)) {
        const newTags = [...tags, newTag];
        onChange(newTags.join(", "));
        setInputValue("");
      }
    } else if (e.key === "Backspace" && !inputValue && tags.length > 0) {
      const newTags = tags.slice(0, -1);
      onChange(newTags.join(", "));
    }
  };

  const removeTag = (indexToRemove: number) => {
    const newTags = tags.filter((_, i) => i !== indexToRemove);
    onChange(newTags.join(", "));
  };

  return (
    <div className="flex flex-wrap gap-2 p-2 border rounded-md bg-white focus-within:ring-2 focus-within:ring-ring focus-within:border-transparent">
      {tags.map((tag, index) => (
        <span key={index} className="flex items-center gap-1 px-2 py-1 text-sm bg-primary/10 text-primary rounded-md">
          {tag}
          <button 
            type="button"
            onClick={() => removeTag(index)}
            className="text-primary hover:text-primary/80 focus:outline-none"
          >
            <X className="w-3 h-3" />
          </button>
        </span>
      ))}
      <input
        type="text"
        className="flex-1 min-w-[120px] outline-none bg-transparent text-sm"
        placeholder={tags.length === 0 ? placeholder : ""}
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
        onKeyDown={handleKeyDown}
        onBlur={() => {
          if (inputValue.trim()) {
            const newTag = inputValue.trim();
            if (!tags.includes(newTag)) {
              onChange([...tags, newTag].join(", "));
              setInputValue("");
            }
          }
        }}
      />
    </div>
  );
}
