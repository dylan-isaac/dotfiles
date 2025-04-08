# T3 Stack

## Definition
The T3 Stack is a modern, opinionated web development stack focused on type safety and developer experience. Created by Theo Ping, it combines TypeScript, tRPC, Tailwind CSS, Next.js, and Prisma to provide a robust foundation for building typesafe, full-stack web applications. The stack emphasizes end-to-end type safety from database to frontend.

## Key Components

1. **TypeScript**: Provides static typing for JavaScript, enabling better tooling, error detection, and code quality
2. **tRPC**: Creates end-to-end type-safe APIs without schemas or code generation
3. **Tailwind CSS**: A utility-first CSS framework for rapid UI development
4. **Next.js**: React framework with server-side rendering, static site generation, and API routes
5. **Prisma**: Type-safe ORM for database access with automatic migrations and schema validation
6. **NextAuth.js** (optional): Authentication solution specifically built for Next.js

## Accessibility Benefits

The T3 Stack offers several advantages for building accessible applications:

1. **Type Safety**: Helps prevent runtime errors that could affect assistive technology interactions
2. **Component-Based Design**: Encourages reusable, consistent UI components with built-in accessibility
3. **Server-Side Rendering**: Improves performance and screen reader compatibility
4. **Tailwind Plugins**: Ecosystem includes accessibility-focused plugins for managing focus, ARIA states, and more
5. **NextAuth Integration**: Provides accessible authentication flows out of the box
6. **Prisma Validation**: Ensures data integrity, which can prevent accessibility issues from invalid data

## Example Implementation

### Creating a New T3 App with Accessibility Focus

```bash
# Create a new T3 application
npx create-t3-app@latest my-accessible-app

# Select the following options:
# - TypeScript: Yes
# - Next.js App Router: Yes
# - Tailwind CSS: Yes
# - tRPC: Yes
# - Prisma: Yes
# - NextAuth.js: Yes
# - Database Provider: PostgreSQL

# Navigate to the new project
cd my-accessible-app

# Install accessibility-related packages
npm install @headlessui/react @tailwindcss/forms axe-core

# Configure axe-core for development testing
touch src/utils/a11y.ts
```

### Implementing Accessible Components with the T3 Stack

```typescript
// src/utils/a11y.ts
// Accessibility testing utility using axe-core

export function initializeA11yTesting() {
  if (typeof window !== 'undefined' && process.env.NODE_ENV !== 'production') {
    import('axe-core').then((axe) => {
      axe.default.run((err, results) => {
        if (err) throw err;
        if (results.violations.length) {
          console.warn('Accessibility issues found:');
          console.table(
            results.violations.map(({ id, impact, description, nodes }) => ({
              id,
              impact,
              description,
              nodes: nodes.length,
            }))
          );
        }
      });
    });
  }
}

// src/app/layout.tsx
// Root layout with accessibility features

import { Inter } from 'next/font/google';
import { type Metadata } from 'next';
import { headers } from 'next/headers';
import { TRPCReactProvider } from '~/trpc/react';
import { initializeA11yTesting } from '~/utils/a11y';
import { ThemeProvider } from '~/components/theme-provider';
import '~/styles/globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
  display: 'swap', // Improves text rendering during font loading
});

export const metadata: Metadata = {
  title: 'Accessible T3 App',
  description: 'A fully accessible application built with the T3 Stack',
  metadataBase: new URL('https://t3-app.example.com'),
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Run a11y tests in development
  if (process.env.NODE_ENV === 'development') {
    initializeA11yTesting();
  }

  return (
    <html 
      lang="en" 
      suppressHydrationWarning
      className={`${inter.variable} font-sans`}
    >
      <head />
      <body>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <TRPCReactProvider headers={headers()}>
            <div className="min-h-screen bg-background">
              <a 
                href="#main-content" 
                className="sr-only focus:not-sr-only focus:absolute focus:z-10 focus:p-4 focus:bg-background focus:text-foreground"
              >
                Skip to main content
              </a>
              <main id="main-content" className="container mx-auto p-4">
                {children}
              </main>
            </div>
          </TRPCReactProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}

// src/components/ui/button.tsx
// Accessible button component example

import * as React from "react";
import { type VariantProps, cva } from "class-variance-authority";
import { cn } from "~/utils/cn";

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/90",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "underline-offset-4 hover:underline text-primary",
      },
      size: {
        default: "h-10 py-2 px-4",
        sm: "h-9 px-3 rounded-md",
        lg: "h-11 px-8 rounded-md",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? "span" : "button";
    
    // Handle keyboard accessibility for span elements used as buttons
    const handleKeyDown = (e: React.KeyboardEvent<HTMLSpanElement>) => {
      if (asChild && (e.key === "Enter" || e.key === " ")) {
        e.preventDefault();
        (e.currentTarget.querySelector("a,button") as HTMLElement)?.click();
      }
    };
    
    const commonProps = {
      className: cn(buttonVariants({ variant, size, className })),
      ref,
      ...props,
    };
    
    if (asChild) {
      return (
        <Comp 
          {...commonProps} 
          role="button" 
          tabIndex={0} 
          onKeyDown={handleKeyDown} 
        />
      );
    }
    
    return <Comp {...commonProps} />;
  }
);

Button.displayName = "Button";

export { Button, buttonVariants };
```

### Configuring Tailwind for Accessibility

```javascript
// tailwind.config.ts
import { type Config } from "tailwindcss";
import { fontFamily } from "tailwindcss/defaultTheme";

export default {
  darkMode: ["class"],
  content: [
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      fontFamily: {
        sans: ["var(--font-sans)", ...fontFamily.sans],
      },
      keyframes: {
        // Reduced motion alternatives for animations
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [
    require("tailwindcss-animate"),
    require("@tailwindcss/forms")({
      strategy: 'class', // Only apply form styles when using the 'form-input' class
    }),
    // Custom focus-visible plugin
    function ({ addVariant }) {
      addVariant("focus-visible", "&:focus-visible");
    },
    // Plugin to respect user's reduced motion settings
    function ({ addBase, theme }) {
      addBase({
        "@media (prefers-reduced-motion: reduce)": {
          "*": {
            "animation-duration": "0.01ms !important",
            "animation-iteration-count": "1 !important",
            "transition-duration": "0.01ms !important",
            "scroll-behavior": "auto !important",
          },
        },
      });
    },
  ],
} satisfies Config;
```

### Type-Safe Server Routes with tRPC and Accessibility Validation

```typescript
// src/server/api/routers/form.ts
import { z } from "zod";
import { createTRPCRouter, publicProcedure, protectedProcedure } from "~/server/api/trpc";

// Define a validation schema that includes accessibility requirements
const contactFormSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Please enter a valid email address"),
  message: z.string().min(10, "Message must be at least 10 characters"),
  // Accessible form metadata
  honeypot: z.string().max(0, "This field must be empty").optional(),
  submittedVia: z.enum(["keyboard", "mouse", "screen-reader", "voice", "other"]).optional(),
});

export const formRouter = createTRPCRouter({
  submitContactForm: publicProcedure
    .input(contactFormSchema)
    .mutation(async ({ ctx, input }) => {
      // Log form submission method for analytics
      if (input.submittedVia) {
        console.log(`Form submitted via: ${input.submittedVia}`);
      }
      
      // Check honeypot field to prevent spam
      if (input.honeypot && input.honeypot.length > 0) {
        throw new Error("Form submission detected as spam");
      }
      
      // Process the form data
      const { name, email, message } = input;
      
      // Store in database
      const submission = await ctx.db.contactSubmission.create({
        data: {
          name,
          email,
          message,
        },
      });
      
      return {
        success: true,
        id: submission.id,
      };
    }),

  // Protected route example
  getSubmissions: protectedProcedure
    .query(async ({ ctx }) => {
      // Only authenticated users can access this
      return await ctx.db.contactSubmission.findMany({
        orderBy: { createdAt: "desc" },
      });
    }),
});
```

### Client-Side Implementation with Accessibility Features

```typescript
// src/components/contact-form.tsx
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "~/components/ui/button";
import { api } from "~/utils/api";

// Define the form schema (same as server-side for type consistency)
const formSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Please enter a valid email address"),
  message: z.string().min(10, "Message must be at least 10 characters"),
  honeypot: z.string().max(0).optional(),
});

type FormValues = z.infer<typeof formSchema>;

export function ContactForm() {
  const [submitMethod, setSubmitMethod] = useState<string>("unknown");
  const [formStatus, setFormStatus] = useState<"idle" | "submitting" | "success" | "error">("idle");
  
  // Set up form with React Hook Form + Zod validation
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: "",
      email: "",
      message: "",
      honeypot: "",
    },
  });
  
  // tRPC mutation for form submission
  const submitForm = api.form.submitContactForm.useMutation({
    onSuccess: () => {
      setFormStatus("success");
      reset();
      
      // Announce success to screen readers
      const statusElement = document.getElementById("form-status");
      if (statusElement) {
        statusElement.textContent = "Your message was sent successfully!";
        statusElement.setAttribute("role", "alert");
      }
    },
    onError: () => {
      setFormStatus("error");
      
      // Announce error to screen readers
      const statusElement = document.getElementById("form-status");
      if (statusElement) {
        statusElement.textContent = "There was an error sending your message. Please try again.";
        statusElement.setAttribute("role", "alert");
      }
    },
  });
  
  // Track interaction method for analytics
  const trackInteraction = (method: string) => {
    setSubmitMethod(method);
  };
  
  // Handle form submission
  const onSubmit = (data: FormValues) => {
    setFormStatus("submitting");
    
    submitForm.mutate({
      ...data,
      submittedVia: submitMethod as any,
    });
  };
  
  return (
    <div className="w-full max-w-md mx-auto">
      <h2 className="text-2xl font-bold mb-4">Contact Us</h2>
      
      {/* Status announcer for screen readers */}
      <div 
        id="form-status" 
        className="sr-only" 
        aria-live="polite"
      ></div>
      
      <form 
        onSubmit={handleSubmit(onSubmit)}
        className="space-y-4"
        onKeyDown={() => trackInteraction("keyboard")}
        onClick={() => trackInteraction("mouse")}
      >
        {/* Name field */}
        <div className="space-y-2">
          <label 
            htmlFor="name"
            className="block text-sm font-medium"
          >
            Name
          </label>
          <input
            id="name"
            type="text"
            className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring focus:ring-primary focus:ring-opacity-50"
            {...register("name")}
            aria-invalid={errors.name ? "true" : "false"}
            aria-describedby={errors.name ? "name-error" : undefined}
          />
          {errors.name && (
            <p id="name-error" className="text-red-500 text-sm" role="alert">
              {errors.name.message}
            </p>
          )}
        </div>
        
        {/* Email field */}
        <div className="space-y-2">
          <label 
            htmlFor="email"
            className="block text-sm font-medium"
          >
            Email
          </label>
          <input
            id="email"
            type="email"
            className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring focus:ring-primary focus:ring-opacity-50"
            {...register("email")}
            aria-invalid={errors.email ? "true" : "false"}
            aria-describedby={errors.email ? "email-error" : undefined}
          />
          {errors.email && (
            <p id="email-error" className="text-red-500 text-sm" role="alert">
              {errors.email.message}
            </p>
          )}
        </div>
        
        {/* Message field */}
        <div className="space-y-2">
          <label 
            htmlFor="message"
            className="block text-sm font-medium"
          >
            Message
          </label>
          <textarea
            id="message"
            rows={4}
            className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring focus:ring-primary focus:ring-opacity-50"
            {...register("message")}
            aria-invalid={errors.message ? "true" : "false"}
            aria-describedby={errors.message ? "message-error" : undefined}
          />
          {errors.message && (
            <p id="message-error" className="text-red-500 text-sm" role="alert">
              {errors.message.message}
            </p>
          )}
        </div>
        
        {/* Honeypot field (hidden from users, helps prevent spam) */}
        <div className="absolute left-[-9999px] top-[-9999px]" aria-hidden="true">
          <label htmlFor="honeypot">Leave this field empty</label>
          <input 
            id="honeypot" 
            type="text" 
            tabIndex={-1}
            {...register("honeypot")} 
          />
        </div>
        
        {/* Submit button */}
        <Button
          type="submit"
          disabled={formStatus === "submitting"}
          className="w-full"
          aria-busy={formStatus === "submitting"}
        >
          {formStatus === "submitting" ? "Sending..." : "Send Message"}
        </Button>
        
        {/* Success message */}
        {formStatus === "success" && (
          <div 
            className="p-3 bg-green-100 border border-green-400 text-green-700 rounded" 
            role="status"
          >
            Your message was sent successfully!
          </div>
        )}
        
        {/* Error message */}
        {formStatus === "error" && (
          <div 
            className="p-3 bg-red-100 border border-red-400 text-red-700 rounded" 
            role="alert"
          >
            There was an error sending your message. Please try again.
          </div>
        )}
      </form>
    </div>
  );
}
```

## Using the T3 Stack in AI Developer Workflows

The T3 Stack works particularly well with AI Developer Workflows (ADWs) due to its strict typing and consistent structure. Here's how to set up an ADW for a T3 project:

```yaml
# adw-t3-config.yaml
name: "T3 App Feature Implementation"
description: "Implements new features in a T3 application with accessibility focus"
version: "1.0.0"

phases:
  - name: "initialization"
    description: "Set up T3 project structure"
    tools:
      - "npx create-t3-app@latest my-t3-app --typescript --tailwind --trpc --prisma --nextAuth"
      - "cd my-t3-app && npm install @headlessui/react @tailwindcss/forms axe-core"
    completion:
      - "my-t3-app/package.json exists"
      - "my-t3-app/src directory exists"

  - name: "component_development"
    description: "Create accessible UI components"
    tools:
      - "cd my-t3-app && aider --model gpt-4o --architect"
    context:
      - "my-t3-app/src/components/"
      - "my-t3-app/src/styles/globals.css"
    tasks:
      - "Create accessible Button component with keyboard support"
      - "Create Form component with proper ARIA attributes"
      - "Add skip link and focus management"
    completion:
      - "my-t3-app/src/components/ui/button.tsx exists"
      - "my-t3-app/src/components/ui/form.tsx exists"

  - name: "api_implementation"
    description: "Implement tRPC API routes"
    tools:
      - "cd my-t3-app && aider --model gpt-4o --architect"
    context:
      - "my-t3-app/src/server/api/routers/"
      - "my-t3-app/prisma/schema.prisma"
    tasks:
      - "Create user router with type-safe endpoints"
      - "Implement form submission with validation"
    completion:
      - "my-t3-app/src/server/api/routers/user.ts exists"
      - "my-t3-app/src/server/api/routers/form.ts exists"

  - name: "accessibility_testing"
    description: "Test and improve accessibility"
    tools:
      - "cd my-t3-app && npm run build"
      - "cd my-t3-app && npm run start"
      - "npx axe-core"
    completion:
      - "No accessibility violations detected"
      - "my-t3-app/accessibility-report.json exists"

accessibility:
  level: "AA"
  requirements:
    - "All interactive elements must be keyboard navigable"
    - "Forms must have proper labels and error handling"
    - "Color contrast must meet WCAG 2.1 AA standards"
    - "All images must have alt text"
    - "Focus management must be implemented"
  testing:
    - "Run axe-core accessibility tests"
    - "Test keyboard navigation"
    - "Verify screen reader compatibility"
```

## Related Terms
- **Create T3 App**: CLI tool for bootstrapping T3 applications with selected features
- **AI Developer Workflow (ADW)**: Structured approach to AI-assisted development
- **End-to-End Type Safety**: Core principle of the T3 Stack
- **tRPC**: Type-safe API layer that eliminates the need for REST/GraphQL schemas
- **Headless UI**: Unstyled, accessible component libraries that pair well with Tailwind
- **WCAG**: Web Content Accessibility Guidelines that T3 apps should follow

## References
- See `https://create.t3.gg/` for official T3 Stack documentation
- See `https://ui.shadcn.com/` for accessible UI components compatible with T3
- See `glossary/ADW.md` for more on AI Developer Workflows
- See `docs/accessibility/wcag-guidelines.md` for accessibility implementation guides 