//
//  HorizontalFloatingHeaderLayout.swift
//  Pods
//
//  Created by Diego Alberto Cruz Castillo on 12/30/15.
//
//

import UIKit

@objc public protocol HorizontalFloatingHeaderLayoutDelegate{
    //Item size
    func collectionView(collectionView: UICollectionView,horizontalFloatingHeaderItemSizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    
    //Header size
    func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderSizeForSectionAtIndex section: Int) -> CGSize
    
    //Section Inset
    optional func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetForSectionAtIndex section: Int) -> UIEdgeInsets
    
    //Item Spacing
    optional func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAtIndex section: Int) -> CGFloat
    
    //Line Spacing
    optional func collectionView(collectionView: UICollectionView,horizontalFloatingHeaderColumnSpacingForSectionAtIndex section: Int) -> CGFloat
}

public class HorizontalFloatingHeaderLayout: UICollectionViewLayout {
    //MARK: - Properties
    //MARK: Headers properties
    //Variables
    var sectionHeadersAttributes: [NSIndexPath:UICollectionViewLayoutAttributes]{
        get{
            return getSectionHeadersAttributes()
        }
    }
    //MARK: Items properties
    //Variables
    var itemsAttributes = [NSIndexPath:UICollectionViewLayoutAttributes]()
    //PrepareItemsAtributes only
    var currentMinX:CGFloat = 0
    var currentMinY:CGFloat = 0
    var currentMaxX:CGFloat = 0
    
    //MARK: - PrepareForLayout methods
    public override func prepareLayout() {
        prepareItemsAttributes()
    }
    
    //Items
    private func prepareItemsAttributes(){
        func resetAttributes(){
            itemsAttributes.removeAll()
            currentMinX = 0
            currentMaxX = 0
            currentMinY = 0
        }
        
        func configureVariables(forSection section:Int){
            let sectionInset = inset(ForSection: section)
            let lastSectionInset = inset(ForSection: section - 1)
            currentMinX = (currentMaxX + sectionInset.left + lastSectionInset.right)
            currentMinY = sectionInset.top + headerSize(forSection: section).height
            currentMaxX = 0.0
        }
        
        func itemAttribute(atIndexPath indexPath:NSIndexPath)->UICollectionViewLayoutAttributes{
            //Applying corrected layout
            func newLineOrigin(size size:CGSize)->CGPoint{
                var origin = CGPointZero
                origin.x = currentMaxX + columnSpacing(forSection: indexPath.section)
                origin.y = inset(ForSection: indexPath.section).top + headerSize(forSection: indexPath.section).height
                return origin
            }
            
            func sameLineOrigin(size size:CGSize)->CGPoint{
                var origin = CGPointZero
                origin.x = currentMinX
                origin.y = currentMinY
                return origin
            }
            
            func updateVariables(itemFrame frame:CGRect){
                currentMaxX = max(currentMaxX,frame.maxX)
                currentMinX = frame.minX
                currentMinY = frame.maxY + itemSpacing(forSection: indexPath.section)
            }
            
            //
            let size = itemSize(ForIndexPath: indexPath)
            let newMaxY = currentMinY + size.height
            let origin:CGPoint
            if newMaxY >  availableHeight(atSection: indexPath.section){
                origin = newLineOrigin(size: size)
            }else{
                origin = sameLineOrigin(size: size)
            }
            let frame = CGRectMake(origin.x, origin.y, size.width, size.height)
            let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attribute.frame = frame
            updateVariables(itemFrame: frame)
            return attribute
        }
        
        //
        resetAttributes()
        let sectionCount = collectionView!.numberOfSections()
        for var section=0;section<sectionCount;section++ {
            configureVariables(forSection: section)
            let itemCount = collectionView!.numberOfItemsInSection(section)
            for var index=0;index<itemCount;index++ {
                let indexPath = NSIndexPath(forRow: index, inSection: section)
                let attribute = itemAttribute(atIndexPath: indexPath)
                itemsAttributes[indexPath] = attribute
            }
        }
    }
    
    //MARK: - LayoutAttributesForElementsInRect methods
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        func attributes(attributes:[NSIndexPath:UICollectionViewLayoutAttributes],containedIn rect:CGRect) -> [UICollectionViewLayoutAttributes]{
            var finalAttributes = [UICollectionViewLayoutAttributes]()
            for (_,attribute) in attributes{
                if rect.intersects(attribute.frame){
                    finalAttributes.append(attribute)
                }
            }
            
            return finalAttributes
        }
        
        //
        let itemsA = attributes(itemsAttributes, containedIn: rect)
        let headersA = Array(sectionHeadersAttributes.values)
        return itemsA + headersA
    }
    
    //MARK: - ContentSize methods
    override public func collectionViewContentSize() -> CGSize {
        func lastItemMaxX()->CGFloat{
            let lastSection = collectionView!.numberOfSections() - 1
            let lastIndexInSection = collectionView!.numberOfItemsInSection(lastSection) - 1
            if let lastItemAttributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: lastIndexInSection, inSection: lastSection)){
                return lastItemAttributes.frame.maxX
            }else{
                return 0
            }
        }
        //
        let lastSection = collectionView!.numberOfSections() - 1
        let contentWidth = lastItemMaxX() + inset(ForSection: lastSection).right
        let contentHeight = collectionView!.bounds.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom
        return CGSizeMake(contentWidth, contentHeight)
    }
    
    //MARK: - LayoutAttributes methods
    //MARK: For ItemAtIndexPath
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let fromIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
        return itemsAttributes[fromIndexPath]
    }
    //MARK: For SupplementaryViewOfKind
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader{
            let fromIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
            return sectionHeadersAttributes[fromIndexPath]
        }else{
            return nil
        }
    }
    
    //MARK: - Utility methods
    //MARK: SectionHeaders Attributes methods
    private func getSectionHeadersAttributes()->[NSIndexPath:UICollectionViewLayoutAttributes]{
        func attributeForSectionHeader(atIndexPath indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes{
            func size()->CGSize{
                return headerSize(forSection: indexPath.section)
            }
            //
            func position()->CGPoint{
                if let itemsCount = collectionView?.numberOfItemsInSection(indexPath.section),
                    let firstItemAttributes = layoutAttributesForItemAtIndexPath(indexPath),
                    let lastItemAttributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: itemsCount-1, inSection: indexPath.section)){
                        let edgeX = collectionView!.contentOffset.x + collectionView!.contentInset.left
                        let xByLeftBoundary = max(edgeX,firstItemAttributes.frame.minX)
                        //
                        let width = size().width
                        let xByRightBoundary = lastItemAttributes.frame.maxX - width
                        let x = min(xByLeftBoundary,xByRightBoundary)
                        return CGPointMake(x, 0)
                }else{
                    return CGPointMake(inset(ForSection: indexPath.section).left, 0)
                }
            }
            //
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
            let myPosition = position()
            let mySize = size()
            let frame = CGRectMake(myPosition.x, myPosition.y, mySize.width, mySize.height)
            attribute.frame = frame
            
            return attribute
        }
        //
        let sectionCount = collectionView!.numberOfSections()
        var attributes = [NSIndexPath:UICollectionViewLayoutAttributes]()
        for var section=0; section<sectionCount;section++ {
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
            attributes[indexPath] = attributeForSectionHeader(atIndexPath: indexPath)
        }
        return attributes
    }
    
    //MARK: - Invalidating layout methods
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        func isSizeChanged()->Bool{
            let oldBounds = collectionView!.bounds
            return oldBounds.width != newBounds.width || oldBounds.height != newBounds.height
        }
        
        func headersIndexPaths()->[NSIndexPath]{
            return Array(sectionHeadersAttributes.keys)
        }
        
        //
        let context = super.invalidationContextForBoundsChange(newBounds)
        if !isSizeChanged(){
            context.invalidateSupplementaryElementsOfKind(UICollectionElementKindSectionHeader, atIndexPaths: headersIndexPaths())
        }
        return context
    }
    
    //MARK: - Utility methods
    private func itemSize(ForIndexPath indexPath:NSIndexPath) -> CGSize{
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate else {return CGSizeZero}
        return delegate.collectionView(collectionView!, horizontalFloatingHeaderItemSizeForItemAtIndexPath: indexPath)
    }
    
    private func headerSize(forSection section:Int) -> CGSize{
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate where section >= 0 else {return CGSizeZero}
        return delegate.collectionView(collectionView!, horizontalFloatingHeaderSizeForSectionAtIndex: section)
    }
    
    private func inset(ForSection section:Int) -> UIEdgeInsets{
        let defaultValue = UIEdgeInsetsZero
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate where section >= 0 else {return defaultValue}
        
        return delegate.collectionView?(collectionView!, horizontalFloatingHeaderSectionInsetForSectionAtIndex: section) ?? defaultValue
    }
    
    private func columnSpacing(forSection section:Int) -> CGFloat{
        let defaultValue:CGFloat = 0.0
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate where section >= 0 else {return defaultValue}
        
        return delegate.collectionView?(collectionView!, horizontalFloatingHeaderColumnSpacingForSectionAtIndex: section) ?? defaultValue
    }
    
    private func itemSpacing(forSection section:Int) -> CGFloat{
        let defaultValue:CGFloat = 0.0
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate where section >= 0 else {return defaultValue}
        return delegate.collectionView?(collectionView!, horizontalFloatingHeaderItemSpacingForSectionAtIndex: section) ?? defaultValue
    }
    
    private func availableHeight(atSection section:Int)->CGFloat{
        func totalInset()->CGFloat{
            let sectionInset = inset(ForSection: section)
            let contentInset = collectionView!.contentInset
            return sectionInset.top + sectionInset.bottom + contentInset.top + contentInset.bottom
        }
        
        //
        guard section >= 0 else {return 0.0}
        return collectionView!.bounds.height - totalInset()
    }
}
