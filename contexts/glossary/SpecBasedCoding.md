# Spec-Based Coding

## Definition
Spec-Based Coding is a software development approach that leverages detailed, structured specifications to guide AI-assisted code generation. This methodology focuses on creating comprehensive requirements documents that serve as prompts for AI models, enabling them to generate accurate, well-structured code that meets both functional requirements and quality standards like accessibility.

## Key Components

1. **Structured Specification**: Detailed requirements document with clear sections and explicit acceptance criteria
2. **Information-Dense Keywords**: Specific technical terminology that provides unambiguous guidance to AI models
3. **Context Files**: Existing code referenced in specifications to establish patterns and conventions
4. **Low-Level Tasks**: Granular implementation steps that guide AI through complex implementations
5. **Acceptance Criteria**: Clear conditions that must be satisfied for the implementation to be considered complete
6. **Accessibility Requirements**: Explicit standards for ensuring the generated code is accessible to all users

## Spec Document Structure

A well-formatted spec document typically includes:

1. **Overview/Objective**: Concise description of the feature being implemented
2. **Implementation Notes**: Technical constraints, libraries, and patterns to utilize
3. **Context Files**: Relevant existing files that should inform the implementation
4. **Tasks**: Step-by-step implementation guidance
5. **Acceptance Criteria**: Testable requirements for success
6. **Accessibility Requirements**: WCAG compliance level and specific considerations

## Example Implementation

### Basic Feature Specification

```markdown
# Specification: Product Filter Component

## Objective
Create an accessible product filter component for an e-commerce application that allows users to filter products by price range, categories, and ratings.

## Implementation Notes
- Use React with TypeScript
- Implement as a pure client-side component
- Follow the existing component patterns in the codebase
- Ensure all interactions work with keyboard navigation
- Make all filter options screen reader accessible

## Context Files
- src/components/ui/Button.tsx
- src/components/ui/Checkbox.tsx
- src/components/ui/Slider.tsx
- src/components/ProductList.tsx
- src/styles/theme.css

## Accessibility Requirements
- WCAG 2.1 AA compliance
- All inputs must have proper labels
- Focus states must be clearly visible
- Filter changes must be announced to screen readers
- Provide keyboard shortcuts for common actions
- Support reduced motion preferences

## Low-Level Tasks
1. Create a FilterContainer component to house all filter controls
2. Implement a dual-handle price range slider with accessible numeric inputs
3. Create collapsible category filter groups with checkboxes
4. Add star rating filter with proper ARIA attributes
5. Implement "Apply Filters" and "Clear All" buttons
6. Add keyboard shortcuts for applying (Alt+Enter) and clearing (Alt+C) filters
7. Ensure all state changes are announced to screen readers

## Acceptance Criteria
1. Users can filter products by price range using a slider or input fields
2. Users can select multiple categories and sub-categories
3. Users can filter by customer rating (1-5 stars)
4. All filters can be applied and cleared using both mouse and keyboard
5. Filter state is visually indicated and announced to screen readers
6. Component passes all WCAG 2.1 AA automated tests
7. Component works properly with screen readers (NVDA, VoiceOver)
8. Component respects users' reduced motion settings
```

### Implementing the Specification (React/TypeScript Example)

```typescript
// src/components/ProductFilter/index.tsx
import React, { useState, useEffect, useRef } from 'react';
import { Button } from '../ui/Button';
import { Checkbox } from '../ui/Checkbox';
import { Slider } from '../ui/Slider';
import { useProductContext } from '../../context/ProductContext';
import { useA11yAnnounce } from '../../hooks/useA11yAnnounce';
import './ProductFilter.css';

interface PriceRange {
  min: number;
  max: number;
}

interface Category {
  id: string;
  name: string;
  subcategories?: Category[];
}

interface ProductFilterProps {
  categories: Category[];
  initialPriceRange: PriceRange;
  maxPrice: number;
  onFilterChange: (filters: FilterState) => void;
}

interface FilterState {
  priceRange: PriceRange;
  selectedCategories: string[];
  minRating: number;
}

export const ProductFilter: React.FC<ProductFilterProps> = ({
  categories,
  initialPriceRange,
  maxPrice,
  onFilterChange,
}) => {
  // State
  const [priceRange, setPriceRange] = useState<PriceRange>(initialPriceRange);
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [minRating, setMinRating] = useState<number>(0);
  const [expandedCategories, setExpandedCategories] = useState<string[]>([]);
  
  // Refs and context
  const filterContainerRef = useRef<HTMLDivElement>(null);
  const { products } = useProductContext();
  const announce = useA11yAnnounce();
  
  // Effect for keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Apply filters with Alt+Enter
      if (e.altKey && e.key === 'Enter') {
        e.preventDefault();
        applyFilters();
      }
      
      // Clear filters with Alt+C
      if (e.altKey && e.key === 'c') {
        e.preventDefault();
        clearFilters();
      }
    };
    
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [priceRange, selectedCategories, minRating]);
  
  // Apply filters
  const applyFilters = () => {
    const filters: FilterState = {
      priceRange,
      selectedCategories,
      minRating,
    };
    
    onFilterChange(filters);
    
    // Announce filter changes to screen readers
    const priceText = `Price range: $${priceRange.min} to $${priceRange.max}.`;
    const categoriesText = selectedCategories.length 
      ? `Categories: ${selectedCategories.length} selected.` 
      : 'No categories selected.';
    const ratingText = minRating > 0 
      ? `Minimum rating: ${minRating} stars.` 
      : 'No minimum rating.';
    
    announce(`Filters applied. ${priceText} ${categoriesText} ${ratingText}`);
  };
  
  // Clear all filters
  const clearFilters = () => {
    setPriceRange(initialPriceRange);
    setSelectedCategories([]);
    setMinRating(0);
    
    onFilterChange({
      priceRange: initialPriceRange,
      selectedCategories: [],
      minRating: 0,
    });
    
    announce('All filters cleared.');
  };
  
  // Handle price input changes
  const handlePriceInputChange = (type: 'min' | 'max', value: string) => {
    const numValue = parseInt(value, 10);
    
    if (isNaN(numValue)) return;
    
    setPriceRange((prev) => {
      const newRange = { ...prev, [type]: numValue };
      
      // Ensure min <= max
      if (type === 'min' && numValue > prev.max) {
        return { ...prev, min: prev.max };
      }
      
      if (type === 'max' && numValue < prev.min) {
        return { ...prev, max: prev.min };
      }
      
      return newRange;
    });
  };
  
  // Toggle category selection
  const toggleCategory = (categoryId: string) => {
    setSelectedCategories((prev) => {
      const isSelected = prev.includes(categoryId);
      
      if (isSelected) {
        return prev.filter(id => id !== categoryId);
      } else {
        return [...prev, categoryId];
      }
    });
  };
  
  // Toggle category expansion (for subcategories)
  const toggleCategoryExpansion = (categoryId: string) => {
    setExpandedCategories((prev) => {
      const isExpanded = prev.includes(categoryId);
      
      if (isExpanded) {
        return prev.filter(id => id !== categoryId);
      } else {
        return [...prev, categoryId];
      }
    });
  };
  
  // Set rating filter
  const handleRatingChange = (rating: number) => {
    setMinRating(rating);
  };
  
  return (
    <div 
      ref={filterContainerRef}
      className="product-filter"
      role="region"
      aria-label="Product filters"
    >
      <h2 className="filter-heading">Filter Products</h2>
      
      {/* Keyboard shortcuts info for screen readers */}
      <div className="sr-only">
        Press Alt+Enter to apply filters. Press Alt+C to clear all filters.
      </div>
      
      {/* Price Range Filter */}
      <section aria-labelledby="price-filter-heading">
        <h3 id="price-filter-heading" className="filter-section-heading">Price Range</h3>
        
        <div className="price-range-inputs">
          <div className="price-input-group">
            <label htmlFor="min-price">Min ($)</label>
            <input
              id="min-price"
              type="number"
              min="0"
              max={maxPrice}
              value={priceRange.min}
              onChange={(e) => handlePriceInputChange('min', e.target.value)}
              aria-valuemin={0}
              aria-valuemax={maxPrice}
              aria-valuenow={priceRange.min}
            />
          </div>
          
          <div className="price-input-group">
            <label htmlFor="max-price">Max ($)</label>
            <input
              id="max-price"
              type="number"
              min="0"
              max={maxPrice}
              value={priceRange.max}
              onChange={(e) => handlePriceInputChange('max', e.target.value)}
              aria-valuemin={0}
              aria-valuemax={maxPrice}
              aria-valuenow={priceRange.max}
            />
          </div>
        </div>
        
        <Slider
          min={0}
          max={maxPrice}
          values={[priceRange.min, priceRange.max]}
          onChange={(values) => setPriceRange({ min: values[0], max: values[1] })}
          aria-labelledby="price-filter-heading"
        />
      </section>
      
      {/* Categories Filter */}
      <section aria-labelledby="category-filter-heading">
        <h3 id="category-filter-heading" className="filter-section-heading">Categories</h3>
        
        <ul className="category-list" role="group" aria-labelledby="category-filter-heading">
          {categories.map((category) => (
            <li key={category.id} className="category-item">
              <div className="category-header">
                <Checkbox
                  id={`category-${category.id}`}
                  checked={selectedCategories.includes(category.id)}
                  onChange={() => toggleCategory(category.id)}
                  aria-label={`Category: ${category.name}`}
                />
                <label htmlFor={`category-${category.id}`}>{category.name}</label>
                
                {category.subcategories && category.subcategories.length > 0 && (
                  <button
                    className="expand-button"
                    onClick={() => toggleCategoryExpansion(category.id)}
                    aria-expanded={expandedCategories.includes(category.id)}
                    aria-controls={`subcategories-${category.id}`}
                  >
                    {expandedCategories.includes(category.id) ? 'Collapse' : 'Expand'}
                  </button>
                )}
              </div>
              
              {/* Subcategories */}
              {category.subcategories && expandedCategories.includes(category.id) && (
                <ul 
                  id={`subcategories-${category.id}`}
                  className="subcategory-list"
                  role="group"
                  aria-label={`${category.name} subcategories`}
                >
                  {category.subcategories.map((subcat) => (
                    <li key={subcat.id} className="subcategory-item">
                      <Checkbox
                        id={`category-${subcat.id}`}
                        checked={selectedCategories.includes(subcat.id)}
                        onChange={() => toggleCategory(subcat.id)}
                        aria-label={`Subcategory: ${subcat.name}`}
                      />
                      <label htmlFor={`category-${subcat.id}`}>{subcat.name}</label>
                    </li>
                  ))}
                </ul>
              )}
            </li>
          ))}
        </ul>
      </section>
      
      {/* Rating Filter */}
      <section aria-labelledby="rating-filter-heading">
        <h3 id="rating-filter-heading" className="filter-section-heading">Minimum Rating</h3>
        
        <div className="rating-selector" role="radiogroup" aria-labelledby="rating-filter-heading">
          {[0, 1, 2, 3, 4, 5].map((rating) => (
            <button
              key={rating}
              className={`rating-button ${minRating === rating ? 'selected' : ''}`}
              onClick={() => handleRatingChange(rating)}
              aria-pressed={minRating === rating}
              aria-label={rating === 0 ? 'No minimum rating' : `${rating} stars or more`}
            >
              {rating === 0 ? 'Any' : '★'.repeat(rating) + '☆'.repeat(5 - rating)}
            </button>
          ))}
        </div>
      </section>
      
      {/* Filter Actions */}
      <div className="filter-actions">
        <Button 
          onClick={applyFilters}
          className="apply-button"
          aria-keyshortcuts="Alt+Enter"
        >
          Apply Filters
        </Button>
        
        <Button 
          onClick={clearFilters}
          variant="secondary"
          className="clear-button"
          aria-keyshortcuts="Alt+C"
        >
          Clear All
        </Button>
      </div>
    </div>
  );
};
```

### Using Spec-Based Coding in AI Developer Workflows

```yaml
# adw-spec-based-coding.yaml
name: "Product Filter Component Implementation"
description: "Implements an accessible product filter component using Spec-Based Coding"
version: "1.0.0"

phases:
  - name: "preparation"
    description: "Set up specification and context"
    tools:
      - "mkdir -p src/components/ProductFilter"
      - "touch src/specs/product-filter-spec.md"
    completion:
      - "src/specs/product-filter-spec.md exists"

  - name: "specification_creation"
    description: "Create detailed specification document"
    tools:
      - "aider --model gpt-4o --ask"
    context:
      - "src/components/ui/Button.tsx"
      - "src/components/ui/Checkbox.tsx"
      - "src/components/ui/Slider.tsx"
    tasks:
      - "Create a detailed spec for an accessible product filter component following WCAG AA standards"
    completion:
      - "src/specs/product-filter-spec.md exists"
      - "src/specs/product-filter-spec.md contains 'Accessibility Requirements'"

  - name: "implementation"
    description: "Implement the component based on specification"
    tools:
      - "aider --model gpt-4o --architect"
    context:
      - "src/specs/product-filter-spec.md"
      - "src/components/ui/Button.tsx"
      - "src/components/ui/Checkbox.tsx"
      - "src/components/ui/Slider.tsx"
    tasks:
      - "Implement ProductFilter component according to the specification"
      - "Create CSS styles for the ProductFilter component"
      - "Implement accessibility features as specified"
    completion:
      - "src/components/ProductFilter/index.tsx exists"
      - "src/components/ProductFilter/ProductFilter.css exists"

  - name: "accessibility_testing"
    description: "Test accessibility compliance"
    tools:
      - "npx axe-core"
      - "aider --model claude-3-sonnet-20240620 --ask"
    tasks:
      - "Run accessibility tests on the implemented component"
      - "Review component for WCAG AA compliance"
      - "Suggest improvements for any accessibility issues"
    completion:
      - "No critical accessibility violations detected"

accessibility:
  level: "AA"
  requirements:
    - "All interactive elements must be keyboard navigable"
    - "Filter changes must be announced to screen readers"
    - "Focus states must be clearly visible"
    - "Color contrast must meet WCAG 2.1 AA standards"
    - "Support reducad motion preferences"
  testing:
    - "Run automated accessibility tests with axe-core"
    - "Manually test keyboard navigation through all controls"
    - "Test with screen readers (NVDA, VoiceOver)"
```

## Benefits of Spec-Based Coding

1. **Predictable Quality**: Detailed specs lead to more consistent, higher-quality code
2. **Accessibility By Design**: Building accessibility requirements into specs ensures they're addressed upfront
3. **Reduced Iterations**: Well-formed specs reduce the need for multiple revision cycles
4. **Knowledge Transfer**: Specs serve as documentation for both AI and human developers
5. **Maintainability**: Code generated from clear specs is typically more maintainable
6. **Accessibility Compliance**: Explicit accessibility requirements ensure generated code meets standards
7. **Audit Trail**: Specs provide a reference point for validating implementation quality

## Best Practices for Accessible Spec-Based Coding

1. **Explicit WCAG Level**: Always specify the target WCAG compliance level (A, AA, or AAA)
2. **Accessibility Section**: Include a dedicated accessibility section in every spec
3. **Screen Reader Considerations**: Specify ARIA attributes and screen reader announcements
4. **Keyboard Navigation**: Detail expected keyboard shortcuts and focus behavior
5. **Color and Contrast**: Specify minimum contrast ratios and alternative indicators
6. **Motion Sensitivity**: Include requirements for respecting reduced motion preferences
7. **Testing Requirements**: List specific accessibility tests that must pass

## Related Terms
- **AI Developer Workflow (ADW)**: Structured approach to AI-assisted development, often using spec-based coding
- **Director Pattern**: Autonomous coding pattern that can be guided by detailed specs
- **Information-Dense Prompting**: Using specific technical terminology in specs to guide AI models
- **WCAG**: Web Content Accessibility Guidelines that should be referenced in accessibility specs
- **Acceptance Criteria**: Specific requirements that must be met for implementation to be considered complete

## References
- See `glossary/ADW.md` for more on AI Developer Workflows
- See `glossary/DirectorPattern.md` for information on autonomous coding patterns
- See `docs/accessibility/wcag-guidelines.md` for accessibility implementation guides 